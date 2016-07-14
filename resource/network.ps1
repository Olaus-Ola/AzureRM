Login-AzureRMAccount

$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
$VnetName = "AzureRmVNet"

$i = 3;
$IpAddressName = 'azurerm-pip-' + $i
$DomainNameLabel = 'azurermdns'+ $i

# Create Public IP 
$pip = New-AzureRmPublicIpAddress -Name $IpAddressName -ResourceGroupName $ResourceGroupName `
                                  -Location $Location -AllocationMethod Static `
                                  -DomainNameLabel $DomainNameLabel


#Remove Public IP 
Remove-AzureRmPublicIpAddress -Name "AzureRmVNet-pip-01" -ResourceGroupName $ResourceGroupName -Force 


# Add Public IP to Existing NIC
$nicName = 'ub-client-nic-1'
$pipName = 'azurerm-pip-3'

$pip = Get-AzureRmPublicIpAddress -Name $pipName -ResourceGroupName $ResourceGroupName 
$nic = Get-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $ResourceGroupName 

$nic.IpConfigurations[0].PublicIpAddress = $pip 
Set-AzureRmNetworkInterface -NetworkInterface $nic







