Login-AzureRmAccount

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
 
$secret = ConvertTo-SecureString -String $jsonEncoded -AsPlainText �Force
Set-AzureKeyVaultSecret -VaultName $VaultName -Name 'cert' -SecretValue $secret