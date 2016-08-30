$ResourceGroupName = 'westeurope'
$Location = 'westeurope'
$VaultName = 'westeuropevau1t'
$secretName = 'key-scr'
$vmName = 'whatever'
$StorageAccountName = "westeurope441"
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
Set-AzureKeyVaultSecret -VaultName $VaultName -Name $secretName -SecretValue $secret

$vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vmName
$vaultId = (Get-AzureRmKeyVault -VaultName $VaultName).ResourceId
$certUrl = (Get-AzureKeyVaultSecret -VaultName $VaultName -Name $secretName).Id
$vm = Add-AzureRmVMSecret -VM $vm -SourceVaultId $vaultId -CertificateStore $certStore -CertificateUrl $certUrl

Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $vm
#returns success, but no cert on server (both 2012r2 and nano)

#returns json error
<#
$pfxFilePath = 'C:\1.pfx'
$pwd = '!Q2w3e4r'
$flag = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
$collection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection 
$collection.Import($pfxFilePath, $pwd, $flag)
$pkcs12ContentType = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12
$clearBytes = $collection.Export($pkcs12ContentType, $pwd)
$fileContentEncoded = [System.Convert]::ToBase64String($clearBytes)
$secret = ConvertTo-SecureString -String $fileContentEncoded -AsPlainText –Force
$secretContentType = 'application/x-pkcs12'
Set-AzureKeyVaultSecret -VaultName $VaultName -Name $secretName -SecretValue $Secret 

$Password = ConvertTo-SecureString -String '!Q2w3e4r' -AsPlainText -Force
Add-AzureKeyVaultKey -VaultName $vaultName -Name 'ITPfx' -KeyFilePath 'C:\1.pfx' -KeyFilePassword $Password
#>

#New-AzureRmResourceGroup -Name “MyResourceGroupName” -Location ‘West US’
#New-AzureRmKeyVault -VaultName “MyKeyVau1tName” -ResourceGroupName “MyResourceGroupName” -Location ‘West US’ -EnabledForDeployment -sku standard
#New-NanoServerAzureVM -Location ‘West US’ –VMName “myvmname” -AdminUsername “testo” -VaultName “MyKeyVau1tName” -ResourceGroupName “MyResourceGroupName” -Verbose
