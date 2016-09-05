Configuration Payload
{
    Param (
    [Parameter(Mandatory=$false)][string] $nodeName,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$storageAccountName

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
             DriveLetter = 'M'
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

       
        xRemoteFile SQLServer2014Package
        {  
             Uri             = "https://" + $storageAccountName + ".blob.core.windows.net/software/en_sql_server_2014_enterprise_edition_with_service_pack_2_x64_dvd_8962401.iso"
             DestinationPath = 'c:\Setup\en_sql_server_2014_enterprise_edition_with_service_pack_2_x64_dvd_8962401.iso'
             DependsOn       = "[File]SetupDir"
        }

    }
}
