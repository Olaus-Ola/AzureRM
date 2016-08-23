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
    $ContainerName = 'ub-node',
    
    [Parameter(Mandatory=$true)]
    [String] 
    $PathToContent

)

$currentLocation = "$PathToContent\$ContainerName"
Set-Location $currentLocation

$relativePath = @()
foreach ($file in (Get-ChildItem $currentLocation -Recurse -File)) {
    $relativePath += $file | Resolve-Path -Relative
}

$relativeDir = @()
foreach ($dir in (Get-ChildItem $currentLocation -Recurse -Directory)) {
    $relativeDir += $dir | Resolve-Path -Relative
}

$stKey = (Get-AzureRMStorageAccountKey -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName).value[0]
$blobContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $stKey

New-AzureStorageContainer -Name $containerName -Context $blobContext

foreach ($rFile in $relativePath) {
    $blobName = $rFile.TrimStart('.\')
    Set-AzureStorageBlobContent -Container $containerName -File $rFile -Context $blobContext -Blob $blobName
}


