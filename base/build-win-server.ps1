Param
(
    [Parameter(Mandatory=$true)]
    [String] 
    $ResourceGroupName,    

    [Parameter(Mandatory=$true)]
    [String] 
    $Location,

    [Parameter(Mandatory=$true)]
    [String] 
    $StorageAccountName,

    [Parameter(Mandatory=$true)]
    [String] 
    $VnetName,    
    
    [Parameter(Mandatory=$true)]
    [Int] 
    $SubnetIndex,

    [Parameter(Mandatory=$true)]
    [String] 
    $VmSize,


    [Parameter(Mandatory=$true)]
    [String] 
    $VmName,

    [Parameter(Mandatory=$true)]
    [String] 
    $NicName

)

# VM Credentials
$username = "Navigator"
$password = ConvertTo-SecureString "Navigator2016" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential `
                   -ArgumentList $username, $password

# Vnet
$vnet = Get-AzureRmVirtualNetwork -Name $VnetName -ResourceGroupName $ResourceGroupName
write-output("VnetName:" + $vnet.Name.ToString())



# Storage Account
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
write-output("StorageAccountName: " + $StorageAccountName + "Id: " + $storageAccount.Id) 


# Nic
$nic = New-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName `
                                   -Name $NicName  -Subnet $vnet.Subnets[$SubnetIndex] -Location $Location -Force


# VM Disk
$diskName = $VmName + "-os-disk"
$osDiskUri = $storageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskName  + ".vhd"


# VM
$publisher = "MicrosoftWindowsServer"
$offer = "WindowsServer"
$sku = "2016-Datacenter-with-Containers"
$version = "2016.0.20170127"

$vm = New-AzureRmVMConfig -VMName $VmName -VMSize $VmSize |
Set-AzureRmVMOperatingSystem  -Windows -ComputerName $VmName -Credential $cred  |
Set-AzureRmVMSourceImage  -PublisherName $publisher -Offer $offer -Skus $sku -Version $version  |
Set-AzureRmVMOSDisk  -Name $diskName -VhdUri $osDiskUri -Caching ReadWrite -CreateOption fromImage | 
Add-AzureRmVMNetworkInterface  -Id $nic.Id

 
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $vm

