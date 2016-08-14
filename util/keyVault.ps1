Login-AzureRmAccount

#https://github.com/Azure/azure-content/blob/master/articles/key-vault/key-vault-get-started.md

$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'

$VaultName = 'AzureRMVault'

New-AzureRmKeyVault -VaultName $VaultName `
                    -ResourceGroupName $ResourceGroupName `
                    -Location $Location `
                    -EnabledForTemplateDeployment `
                    -EnabledForDeployment `
                    -Sku standard 

Get-AzureRmKeyVault -VaultName $VaultName  -ResourceGroupName $ResourceGroupName


## Create Certificate (VS CLI)
#makecert -sky exchange -r -n "CN=azurermvault.vault.azure.net" -pe -a sha1 -len 2048 -ss My -sv C:\temp\azurermvault.pvk C:\temp\azurermvault.cer 
#pvk2pfx -pvk C:\\temp\azurermvault.pvk -pi <put the password here> -spc C:\\temp\\azurermvault.cer -pfx C:\\temp\\azurermvault.pfx


## Add Certificate to Vault   

$password = <put the password here>
$fileName = "C:\Temp\azurermvault.pfx"
$fileContentBytes = get-content $fileName -Encoding Byte
$fileContentEncoded = [System.Convert]::ToBase64String($fileContentBytes)
 

$jsonObject = @"
{
"data": "$filecontentencoded",
"dataType" :"pfx",
"password": $password
}
"@
 
$jsonObjectBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonObject)
$jsonEncoded = [System.Convert]::ToBase64String($jsonObjectBytes)
 
$secret = ConvertTo-SecureString -String $jsonEncoded -AsPlainText –Force
Set-AzureKeyVaultSecret -VaultName $VaultName -Name 'cert' -SecretValue $secret