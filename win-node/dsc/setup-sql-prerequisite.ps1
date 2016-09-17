Configuration Payload
{
    Param (
    [Parameter(Mandatory=$false)][string] $nodeName,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$storageAccountName,
    [Parameter(Mandatory)][ValidateSet("2014","2016")][String]$sqlVersion,
    [Parameter(Mandatory)][bool]$managementstudio    
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

        File SetupDir
        {
            Type = 'Directory'
            DestinationPath = 'c:\Setup'
            Ensure = "Present"    
        }

       WindowsFeature "NET-Framework-Core"
       {
          Name = "NET-Framework-Core"
          Ensure = "Present"
       }

        if ($sqlVersion -eq "2014") {
            xRemoteFile SQLServer2014Package
            {  
                Uri             = "https://" + $storageAccountName + ".blob.core.windows.net/software/en_sql_server_2014_enterprise_edition_with_service_pack_2_x64_dvd_8962401.iso"
                DestinationPath = 'c:\Setup\en_sql_server_2014_enterprise_edition_with_service_pack_2_x64_dvd_8962401.iso'
                DependsOn       = "[File]SetupDir"
            }
        }
        else {            
            
            xRemoteFile SQLServer2016Package
            {  
                Uri             = "https://" + $storageAccountName + ".blob.core.windows.net/software/en_sql_server_2016_enterprise_x64_dvd_8701793.iso"
                DestinationPath = 'c:\Setup\en_sql_server_2016_enterprise_x64_dvd_8701793.iso'
                DependsOn       = "[File]SetupDir"
            }

            xRemoteFile SQLServerMangementPackage
            {  
                Uri             = "http://go.microsoft.com/fwlink/?LinkID=824938"
                DestinationPath = 'c:\Setup\SSMS-Setup-ENU.exe'
                DependsOn       = "[File]SetupDir"
            }
        }

        if ($managementstudio) {
            xRemoteFile ManagementStudioPackage
            {  
                Uri             = "http://go.microsoft.com/fwlink/?LinkID=824938"
                DestinationPath = 'c:\Setup\SSMS-Setup-ENU.exe'
                DependsOn       = "[File]SetupDir"
            }

            Package ManagementStudio
            {
                Ensure = "Present"
                Path = "C:\Setup\SSMS-Setup-ENU.exe"
                Arguments = "/q /norestart"
                Name = "ManagementStudio"
                ProductId = "446B31DB-00FC-4EEF-8B13-7F5F8A38F026"
                DependsOn = "[xRemoteFile]ManagementStudioPackage"
            }
        }
    }
}