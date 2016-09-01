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
    $VmName
    
)

$vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupNamep -Name $VmName
$diskName = $VmName + "data-disk"


### THIS NEEDS TO BE CHANGED
$VhdUri = "https://azurestoragez1.blob.core.windows.net/vhds/" + $VmName  + "-data.vhd"


Add-AzureRmVMDataDisk -VM $vm -Name $diskName -VhdUri $VhdUri `
                      -LUN 0 -Caching ReadOnly -DiskSizeInGB 1023 -CreateOption empty


Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $vm
