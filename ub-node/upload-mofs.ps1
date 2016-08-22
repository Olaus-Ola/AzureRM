$rg = Get-AzureRmResourceGroup 'put_name_here'
$st = Get-AzureRmStorageAccount -ResourceGroupName $rg.ResourceGroupName
$stKey = (Get-AzureRMStorageAccountKey -StorageAccountName $st.StorageAccountName -ResourceGroupName $rg.ResourceGroupName).value[0]

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
