Login-AzureRMAccount

Get-AzureRmSubscription | Format-Table
Get-AzureRmSubscription | Out-GridView


$ResourceGroupName = 'ansible-resource'
$Location = 'Canada Central'
$VnetName = "Ansible-network"
$VNetAddressPrefix = "10.0.0.0/28"


#region Create Resource Group

$ResourceGroup = @{
    Name = $ResourceGroupName;
    Location = $Location;
    Force = $true;
}

New-AzureRmResourceGroup @ResourceGroup;

#Set ResourceGroup Properties
Set-AzureRmResourceGroup -Name $ResourceGroupName -Tag @{Name="Department";Value="IT"}

# Get Azure Resource Groups 
Get-AzureRmresourceGroup | Select ResourceGroupName
Get-AzureRmresourceGroup | Out-GridView


#endregion


#region Create VNet

$vnet = New-AzureRmVirtualNetwork -Name $VnetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VNetAddressPrefix

#endregion



#region Subnet Properties 

$index = 0

$vnet = Get-AzureRmVirtualNetwork -Name $VnetName  -ResourceGroupName $ResourceGroupName 
$vnet.Subnets[$index].Id 
$vnet.Subnets[$index].AddressPrefix
$vnet.Subnets[$index].Name

#endregion