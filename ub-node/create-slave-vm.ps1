#Login-AzureRMAccount

$ResourceGroupName = "ansible-resource"
$Location = "Canada Central"
$VnetName = "Ansible-network"
$SubNetIndex = 0
$NicName= "manager2-nic"

$StorageAccountName = "ansiblestorage635"

$ipName = "manager2-ip"

$TemplateUri= "C:\Users\Pari\Desktop\harpreet\Auto-deploy-docker-azure\ub-node\slave_template.json"
$parameterFile= "C:\Users\Pari\Desktop\harpreet\Auto-deploy-docker-azure\ub-node\slave_parameter.json"

# Pip

$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic 

# Vnet
$vnet = Get-AzureRmVirtualNetwork -Name $VnetName -ResourceGroupName $ResourceGroupName
write-output("VnetName:" + $vnet.Name.ToString())
# Nic
$nic = New-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Subnet $Vnet.Subnets[$SubnetIndex] -Location $Location -PublicIpAddress $pip -Name $NicName


#Build VM
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateUri -TemplateParameterFile $parameterFile


