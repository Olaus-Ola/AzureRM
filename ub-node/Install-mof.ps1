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
    $MOFfile,

    [Parameter(Mandatory=$true)]
    [String] 
    $VmName


)

$extensionName = 'DSCForLinux'
$publisher = 'Microsoft.OSTCExtensions'
$version = '2.0'


$storageAccountKey = (Get-AzureRMStorageAccountKey -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName).value[0]
write-output("storageAccountKey: " + $storageAccountKey)

$privateConfig = @"
{{
	"StorageAccountName": "{0}",
	"StorageAccountKey": "{1}"
}}
"@ -f $StorageAccountName,$storageAccountKey


$fileUri = "http://$StorageAccountName.blob.core.windows.net/mof/$MOFfile";
write-output($fileUri)


$publicConfig = @"
{{
	"Mode": "Push",
	"FileUri": "{0}"
}}
"@ -f $fileUri 


Set-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VmName -Location $Location `
                       -Name $extensionName -Publisher $publisher -ExtensionType $extensionName `
                       -TypeHandlerVersion $version -SettingString $publicConfig -ProtectedSettingString $privateConfig













