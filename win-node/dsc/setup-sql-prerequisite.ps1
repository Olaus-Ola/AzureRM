Configuration Payload
{
    Param (
    [Parameter(Mandatory=$false)][string] $nodeName,

    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$DatabaseName,

    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$SqlServerVersion,

    [PSCredential]$Credentials

    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xDatabase
    Import-DscResource -ModuleName xStorage

    Node $nodeName
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        xWaitforDisk Disk2
        {
             DiskNumber = 1
             RetryIntervalSec = 60
             RetryCount = 60
        }

        xDisk DataVolume
        {
             DiskNumber = 1
             DriveLetter = 'D'
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
             Uri             = "https://azurestoragez1.blob.core.windows.net/software/DownloadTestFile.txt"
             DestinationPath = "c:\Setup\DownloadTestFile.txt"
             DependsOn       = "[File]SetupDir"
        }

    }
}


