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
    $MOFfile

)


$extensionName = 'DSCForLinux'
$publisher = 'Microsoft.OSTCExtensions'
$version = '2.0'


# MOF File in Blob Storage - Directory/File Must be in place
$fileDirectory = 'mof';
$mofFile = 'localhost.mof';
#$fileUri = "http://$StorageAccountName.blob.core.windows.net/$ContainerName/$mofFile";

$fileUri = "http://azurestoragez1.blob.core.windows.net/mof/localhost.mof";



$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName).Value[0]

write-output("File Uri:" + $fileUri)
write-output("StorageAccountName:" + $StorageAccountName)
write-output("Primary StorageKey:" + $storageAccountKey)
write-output("-----------------------------------------")

#Blob Storage Container
 $publicConfig = '{
    "Mode": "Push",
    "FileUri": "http://azurestoragez1.blob.core.windows.net/mof/localhost.mof" 
  }'


write-output($publicConfig)





#$stoname = "Push";

$ProtectedSettingsString = '{"Mode":"' + "Push" + '","FileUri":"' + "http://azurestoragez1.blob.core.windows.net/mof/localhost.mof" + '"}';
write-output($ProtectedSettingsString)


 $privateConfig = '{
  "StorageAccountName": "azurestoragez1",
  "StorageAccountKey": "69RJAF5mQP0f6GfhDwL6PlNFLkEZ/FelyTg65+FDiCbTwMfwkIojLl+d73BdJc84kW+h/QXezj5yXe1TVA/T/g=="
  }'


#Set-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VmName -Location $Location `
 #                      -Name $extensionName -Publisher $publisher -ExtensionType $extensionName `
  #                     -TypeHandlerVersion $version -SettingString $publicConfig -ProtectedSettingString $privateConfig
