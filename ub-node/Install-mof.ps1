Param
(
    [Parameter(Mandatory=$true)]
    [String] 
    $ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [String] 
    $StorageAccountNamee,


    [Parameter(Mandatory=$true)]
    [String] 
    $ContainerName,

    [Parameter(Mandatory=$true)]
    [String] 
    $MOFfile,

    [Parameter(Mandatory=$true)]
    [String] 
    $VmName
)


$storageAccountKey = (Get-AzureRMStorageAccountKey -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName).value[0]










$mofname = 'put_mof_name_here'
$configurationpath = 'put_.ps1_path_here'

$mofpath = $StorageAccount | Publish-AzureRmVMDscConfiguration -ConfigurationPath $configurationpath

$rgName = $rg.ResourceGroupName
$vmName = $vm.Name
$location = 'putlocationhere'
$extensionName = 'DSCForLinux'
$publisher = 'Microsoft.OSTCExtensions'
$version = '2.0'



$privateConfig = @"
{{
	"StorageAccountName": "{0}",
	"StorageAccountKey": "{1}"
}}
"@ -f $st.StorageAccountName,$stKey

$publicConfig = @"
{{
  "Mode": "Install",
  "FileUri": "{0}"
}}
"@ -f $mofpath


Set-AzureRmVMExtension -Publisher $publisher -ResourceGroupName $rgName -VMName $vmName `
 -ExtensionType $extensionName -Location $location -TypeHandlerVersion $version `
 -SettingString $publicConfig -ProtectedSettingString $privateConfig -Name $mofname -ForceRerun $true
