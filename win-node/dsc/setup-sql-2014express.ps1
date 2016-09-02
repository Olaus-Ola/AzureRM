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

    Node $nodeName
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
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

        xRemoteFile DacPacPackage
        {  
             Uri             = "https://github.com/stuartshay/CoreDataStore/raw/master/data/SQLDataTier/NycLandmarks.dacpac"
             DestinationPath = "c:\Setup\NycLandmarks.dacpac"
             DependsOn       = "[File]SetupDir"
        } 
        
        xRemoteFile BacPacPackage
        {  
             Uri             = "https://github.com/stuartshay/CoreDataStore/raw/master/data/SQLDataTier/NycLandmarks.bacpac"
             DestinationPath = "c:\Setup\NycLandmarks.bacpac"
             DependsOn       = "[File]SetupDir"
        }

        xRemoteFile SQLServerPackage
        {  
             Uri             = "https://azurestoragez1.blob.core.windows.net/software/DownloadTestFile.txt"
             DestinationPath = "c:\Setup\DownloadTestFile.txt"
             DependsOn       = "[File]SetupDir"
        }

        xDatabase DeployBacPac
        {
            Ensure = "Present"
            SqlServer = $nodeName
            SqlServerVersion = $SqlServerVersion
            DatabaseName = $DatabaseName
            Credentials = $Credentials
            BacPacPath = "c:\Setup\NycLandmarks.bacpac"
        }
    }
}

$cd = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

$cred = Get-Credential -UserName sa -Message "Password please"
