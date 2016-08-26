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
$blobContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $stKey

if (!(Get-AzureStorageContainer -Name $containerName -Context $blobContext)) {
    New-AzureStorageContainer -Name $containerName -Context $blobContext
}

foreach ($rFile in $relativePath) {
    $blobName = $rFile.TrimStart('.\')
    Set-AzureStorageBlobContent -Container $containerName -File $rFile -Context $blobContext -Blob $blobName -Force
}

Set-Location ..\..
