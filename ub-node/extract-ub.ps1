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
    $ContainerName,

    [Parameter(Mandatory=$true)]
    [String] 
    $VmName,

    [Parameter(Mandatory=$true)]
    [String] 
    $NicName,

    [Parameter(Mandatory=$true)]
    [String] 
    $VhdNamePrefix
)


$diskName = $vmName + '-os-disk.vhd';
$path = $vhdNamePrefix + ".json"


#Linux Server 
Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vmName
Set-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vmName -Generalized
Save-AzureRmVMImage -ResourceGroupName $ResourceGroupName -Name $vmName -DestinationContainerName $ContainerName -VHDNamePrefix $VhdNamePrefix -Path $path

# Remove Resources
Remove-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vmName
Remove-AzureRmNetworkInterface -Name $NicName -ResourceGroupName $ResourceGroupName -Force 

#Remove VHD Disk
$storageContext = (Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName).Context
Remove-AzureStorageBlob -Blob $diskName -Container vhds -Context $storageContext