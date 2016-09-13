Login-AzureRMAccount

$ResourceGroupName = 'docker-resource'
$Location = 'Canada Central'
$VnetName = "docker-network"

$i = 0;
$IpAddressName = 'azurerm-pip-' + $i
$DomainNameLabel = 'azurermdns'+ $i

# Create Public IP 
$pip = New-AzureRmPublicIpAddress -Name $IpAddressName -ResourceGroupName $ResourceGroupName `
                                  -Location $Location -AllocationMethod Static `
                                  -DomainNameLabel $DomainNameLabel

 # Add Public IP to Existing NIC
$nicName = 'ub-client-nic-0'
$pipName = 'azurerm-pip-0'

$pip = Get-AzureRmPublicIpAddress -Name $pipName -ResourceGroupName $ResourceGroupName 
$nic = Get-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $ResourceGroupName 

$nic.IpConfigurations[0].PublicIpAddress = $pip 
Set-AzureRmNetworkInterface -NetworkInterface $nic


#Remove Public IP 
#Remove-AzureRmPublicIpAddress -Name "AzureRmVNet-pip-0" -ResourceGroupName $ResourceGroupName -Force





