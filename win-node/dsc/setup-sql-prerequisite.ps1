Configuration Payload
{
    Param (
    [Parameter(Mandatory=$false)][string] $nodeName,
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][String]$storageAccountName,
    [Parameter(Mandatory)][ValidateSet("2014","2016")][String]$sqlVersion,
    [Parameter(Mandatory=$false)][bool]$managementStudio    
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xStorage

    Node $nodeName
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
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
                MatchSource     = $false
            }
        }
        else {            
            
            xRemoteFile SQLServer2016Package
            {  
                Uri             = "https://" + $storageAccountName + ".blob.core.windows.net/software/en_sql_server_2016_enterprise_x64_dvd_8701793.iso"
                DestinationPath = 'c:\Setup\en_sql_server_2016_enterprise_x64_dvd_8701793.iso'
                DependsOn       = "[File]SetupDir"
                MatchSource     = $false
            }
        }

        if ($managementStudio) {

            xRemoteFile SQLServerMangementPackage
            {  
                Uri             = "http://go.microsoft.com/fwlink/?LinkID=824938"
                DestinationPath = 'c:\Setup\SSMS-Setup-ENU.exe'
                DependsOn       = "[File]SetupDir"
                MatchSource     = $false
            }
        }
    }
}