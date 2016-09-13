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
    $PathToContent

)

$currentLocation = Set-Location $PathToContent

$relativePath = @()
foreach ($file in (Get-ChildItem $currentLocation -Recurse -File)) {
    $relativePath += $file | Resolve-Path -Relative
}

$stKey = (Get-AzureRMStorageAccountKey -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName).value[0]
$StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $stKey

if (!(Get-AzureStorageContainer -Name $containerName -Context $StorageContext -ea 0)) {
    New-AzureStorageContainer -Name $containerName -Context $StorageContext
}

foreach ($rFile in $relativePath) {
    $blobName = $rFile.TrimStart('.\')
    Set-AzureStorageBlobContent -Container $containerName -File $rFile -Context $StorageContext -Blob $blobName -Force
}

Set-Location ..\..
