Param
(
    [Parameter(Mandatory=$true)]
    [String] 
    $ResourceGroupName,    

    [Parameter(Mandatory=$true)]
    [String] 
    $Location,

    [Parameter(Mandatory=$true)]
    [String] 
    $vmName,

    [Parameter(Mandatory=$true)]
    [String] 
    $VaultName,

    [Parameter(Mandatory=$true)]
    [String] 
    $vaultSecretName,

    [Parameter(Mandatory=$true)]
    [String] 
    $password
)

$tempPath = [System.IO.Path]::GetTempFileName()
$cert = New-SelfSignedCertificate -DnsName "*.$Location.cloudapp.azure.com" -CertStoreLocation Cert:\LocalMachine\My
Export-PfxCertificate -Cert cert:\localmachine\my\$($cert.Thumbprint) -FilePath $tempPath -Password (ConvertTo-SecureString -Force -AsPlainText -String $password)
 
New-AzureRmKeyVault -VaultName $vaultName `
                    -ResourceGroupName $resourceGroupName `
                    -Location $Location `
                    -EnabledForTemplateDeployment `
                    -EnabledForDeployment `
                    -Sku standard 
 
$fileContentBytes = get-content $tempPath -Encoding Byte
$fileContentEncoded = [System.Convert]::ToBase64String($fileContentBytes)
Remove-Item $tempPath 
$jsonObject = @"
{
"data": "$fileContentEncoded",
"dataType" :"pfx",
"password": $password
}
"@
 
$jsonObjectBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonObject)
$jsonEncoded = [System.Convert]::ToBase64String($jsonObjectBytes)
$vaultSecret = Set-AzureKeyVaultSecret -VaultName $vaultName -Name $vaultSecretName -SecretValue (ConvertTo-SecureString -Force -AsPlainText -String $jsonEncoded)

#$vm = Add-AzureRmVMSecret -VM $vm -SourceVaultId $vaultId -CertificateStore $certStore -CertificateUrl $certUrl
#Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $vm
#returns success, but no cert on server (both 2012r2 and nano), turns out sometimes it works, but pretty randomly.
#I would advice against using this shit.

$parameters = @{
    "vmName" = $vmName
    "resourceGroup" = $ResourceGroupName
    "templateUri" = "https://raw.githubusercontent.com/stuartshay/AzureRM/master/win-node/nano/arm-addcertificate.json"
    "vaultName" = $vaultName
    "vaultResourceGroup" = $resourceGroupName
    "secretUrlWithVersion" = $($vaultSecret.id)
}
New-AzureRmResourceGroupDeployment @parameters