## Azure Utilities

### Azure Key Vault 

[Azure Key Vault Getting Started](https://github.com/Azure/azure-content/blob/master/articles/key-vault/key-vault-get-started.md)


#### Create Certificate (VS CLI)

````
#makecert -sky exchange -r -n "CN=azurermvault.vault.azure.net" -pe -a sha1 -len 2048 -ss My -sv C:\temp\azurermvault.pvk C:\temp\azurermvault.cer 
#pvk2pfx -pvk C:\\temp\azurermvault.pvk -pi <put the password here> -spc C:\\temp\\azurermvault.cer -pfx C:\\temp\\azurermvault.pfx
````

