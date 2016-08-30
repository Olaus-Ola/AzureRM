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
    $File

)

$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName).Value[0]
$StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageAccountKey

write-output("Storage Account Name: " + $StorageAccountName)
write-output("Primary StorageKey: " + $storageAccountKey)

if (!(Get-AzureStorageContainer -Name $containerName -Context $StorageContext -ea 0)) {
    New-AzureStorageContainer -Name $containerName -Context $StorageContext
}

$UploadFile = @{
    Context = $StorageContext; 
    Container = $ContainerName;
    File = $File
}

Set-AzureStorageBlobContent @UploadFile;



















