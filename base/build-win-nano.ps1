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
    $VaultName,


    [Parameter(Mandatory=$true)]
    [String] 
    $VnetName,    
    
    [Parameter(Mandatory=$true)]
    [Int] 
    $SubnetIndex,

    [Parameter(Mandatory=$true)]
    [String] 
    $VmSize,


    [Parameter(Mandatory=$true)]
    [String] 
    $VmName,

    [Parameter(Mandatory=$true)]
    [String] 
    $NicName,


    [Parameter(Mandatory=$false)]
    [String] 
    $BaseImage
)


write-output("ResourceGroupName " + $ResourceGroupName.ToString())
write-output("VaultName " + $VaultName.ToString())








Write-Verbose "Explicit arg VM name: $VMName"
Write-Verbose "Explicit arg VM size: $VMSize"
Write-Verbose "Explicit arg admin user name: $AdminUsername"
Write-Verbose "Explicit arg storage account name: $StorageAccountName"
Write-Verbose "Explicit arg VM location: $Location"
Write-Verbose "Explicit arg key vault name: $VaultName"
Write-Verbose "Explicit arg resource group name: $ResourceGroupName"
Write-Verbose "Explicit arg image SKU: $ImageSku"







#New-NanoServerImage -DeploymentType Guest -Edition Standard -MediaPath \\Path\To\Media\en_us -BasePath .\Base -TargetPath .\NanoServer.wim -Development