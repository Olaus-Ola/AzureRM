Configuration Payload
{
    Param (
    [Parameter(Mandatory=$false)][string] $nodeName,
    #[Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$SqlServerVersion,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$DownloadUri

    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 3.13.0.0
    Import-DscResource -ModuleName xStorage -ModuleVersion 2.6.0.0

    Node $nodeName
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        xWaitforDisk Disk2
        {
             DiskNumber = 2
             RetryIntervalSec = 60
             RetryCount = 60
        }

        xDisk DataVolume
        {
             DiskNumber = 2
             DriveLetter = 'Q'
             AllocationUnitSize = 64kb
        }

        WindowsFeature "Framework 3.5"
        {
            Name = "NET-Framework-Core"
            Ensure = "Present"
        }

        File SetupDir
        {
            Type = 'Directory'
            DestinationPath = 'c:\Setup'
            Ensure = "Present"    
        }

       
        xRemoteFile SQLServerPackage
        {  
             Uri             = $DownloadUri
             DestinationPath = 'c:\Setup'
             DependsOn       = "[File]SetupDir"
        }
    }
}
