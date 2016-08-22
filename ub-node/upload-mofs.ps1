$rg = Get-AzureRmResourceGroup 'putnamehere'
$st = Get-AzureRmStorageAccount -ResourceGroupName $rg.ResourceGroupName
$mofname

$mofpath = $StorageAccount | Publish-AzureRmVMDscConfiguration -ConfigurationPath $mofpath

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
