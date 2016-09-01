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
    $VmName,

    [Parameter(Mandatory=$true)]
    [String] 
    $StorageAccountName,

    [Parameter(Mandatory=$true)]
    [String] 
    $DiskName

)

$vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupNamep -Name $VmName

$VhdUri = "https://STORAGEACCOUNTNAME.blob.core.windows.net/vhds/VMNAME-data-disk-DISKNAME.vhd"
$VhdUri = $VhdUri.Replace("STORAGEACCOUNTNAME", $StorageAccountName)
$VhdUri = $VhdUri.Replace("VMNAME", $VmName)
$VhdUri = $VhdUri.Replace("DISKNAME", $DiskName)


Add-AzureRmVMDataDisk -VM $vm -Name $diskName -VhdUri $VhdUri `
                      -LUN 0 -Caching ReadOnly -DiskSizeInGB 1023 -CreateOption empty


Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $vm
