$rg = Get-AzureRmResourceGroup 'putnamehere'
$st = Get-AzureRmStorageAccount -ResourceGroupName $rg.ResourceGroupName

$containerName = "ub-node"

$currentLocation = "C:\Users\_\Downloads\AzureRM-master\ub-node"
Set-Location $currentLocation
$relativePath = @()
foreach ($file in (Get-ChildItem $currentLocation -Recurse -File)) {
    $relativePath += $file | Resolve-Path -Relative
}
$relativeDir = @()
foreach ($dir in (Get-ChildItem $currentLocation -Recurse -Directory)) {
    $relativeDir += $dir | Resolve-Path -Relative
}

$stKey = (Get-AzureRMStorageAccountKey -StorageAccountName $st.StorageAccountName -ResourceGroupName $rg.ResourceGroupName).value[0]
$blobContext = New-AzureStorageContext -StorageAccountName $st.StorageAccountName -StorageAccountKey $stKey

New-AzureStorageContainer -Name $containerName -Context $blobContext
foreach ($rFile in $relativePath) {
    $blobName = $rFile.TrimStart('.\')
    Set-AzureStorageBlobContent -Container $containerName -File $rFile -Context $blobContext -Blob $blobName
}
