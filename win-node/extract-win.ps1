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


$path = $VhdNamePrefix + ".json"

#Windows Server - after sysprep
Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vmName
Set-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vmName -Generalized
Save-AzureRmVMImage -ResourceGroupName $ResourceGroupName -Name $vmName -DestinationContainerName "vm-images" -VHDNamePrefix $vhdNamePrefix -Path $path


# Remove Resources
Remove-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $ResourceGroupName -Force 
Remove-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vmName