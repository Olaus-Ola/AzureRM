Login-AzureRMAccount

$ResourceGroupName = 'ansible-resource'
$Location = 'Canada Central'
$VnetName = "Ansible-network"

##Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only
## The name is FQDN in Azure (Choose a name that has not been taken 
 
$StorageAccountName = "ansiblestorage635"

New-AzureRmStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName `
                          -Type Standard_LRS -Location $Location

