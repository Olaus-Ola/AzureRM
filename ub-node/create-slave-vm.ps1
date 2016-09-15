#Login-AzureRMAccount

$ResourceGroupName = "ansible-resource"
$Location = "Canada Central"
$VnetName = "Ansible-network"
$SubNetIndex = 0
$NicName= "worker1"

$StorageAccountName = "ansiblestorage635"

$ipName = "worker1ip"

$TemplateUri= "slave_template.json"
$parameterFile= "slave_parameter.json"

# Pip

$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic 

# Vnet
$vnet = Get-AzureRmVirtualNetwork -Name $VnetName -ResourceGroupName $ResourceGroupName
write-output("VnetName:" + $vnet.Name.ToString())
# Nic
$nic = New-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Subnet $Vnet.Subnets[$SubnetIndex] -Location $Location -PublicIpAddress $pip -Name $NicName


#Build VM
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateUri -TemplateParameterFile $parameterFile


