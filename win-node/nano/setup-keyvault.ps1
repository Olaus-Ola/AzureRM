$ResourceGroupName = 'azurerm'
$Location = 'eastus2'
$VaultName = 'bault'
$secretName = 'bigscrt'
$vmName = 'certesto'
$StorageAccountName = "azurestoragez2"
$certStore = "My"

New-SelfSignedCertificate -DnsName "*.westeurope.cloudapp.azure.com" -CertStoreLocation Cert:\LocalMachine\My
Export-PfxCertificate -Cert cert:\localmachine\my\B5CF5418484E65C02C7AE4C0FE352DD4AAC16CE3 -FilePath c:\1.pfx -Password (ConvertTo-SecureString -String '!Q2w3e4r' -Force -AsPlainText)
 
New-AzureRmKeyVault -VaultName $VaultName `
                    -ResourceGroupName $ResourceGroupName `
                    -Location $Location `
                    -EnabledForTemplateDeployment `
                    -EnabledForDeployment `
                    -Sku standard 
 
$fileName = "C:\1.pfx"
$fileContentBytes = get-content $fileName -Encoding Byte
$fileContentEncoded = [System.Convert]::ToBase64String($fileContentBytes)
 
$jsonObject = @"
{
"data": "$filecontentencoded",
"dataType" :"pfx",
"password": "!Q2w3e4r"
}
"@
 
$jsonObjectBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonObject)
$jsonEncoded = [System.Convert]::ToBase64String($jsonObjectBytes)
 
$secret = ConvertTo-SecureString -String $jsonEncoded -AsPlainText –Force
Set-AzureKeyVaultSecret -VaultName $VaultName -Name gg -SecretValue $secret

$vaultsecret = Get-AzureKeyVaultSecret -VaultName $VaultName -Name gg
#$vm = Add-AzureRmVMSecret -VM $vm -SourceVaultId $vaultId -CertificateStore $certStore -CertificateUrl $certUrl

#Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $vm
#returns success, but no cert on server (both 2012r2 and nano)

$parameters = @{
    "vmName" = $vmName
    "resourceGroup" = $ResourceGroupName
    "templateUri" = "https://raw.githubusercontent.com/stuartshay/AzureRM/master/win-node/nano/arm-addcertificate.json"
    "vaultName" = $VaultName
    "vaultResourceGroup" = $ResourceGroupName
    "secretUrlWithVersion" = $($vaultsecret.id)
}
New-AzureRmResourceGroupDeployment @parameters