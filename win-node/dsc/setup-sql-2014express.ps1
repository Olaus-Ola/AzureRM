Configuration Payload
{
    
    Param (
    [Parameter(Mandatory=$false)][string] $nodeName
    )
    
    Import-DscResource –ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource –ModuleName 'xPSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'cChoco'
    Import-DscResource -ModuleName 'xDatabase'
    
    Node $nodeName
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        File ChocoDir
        {
            Type = 'Directory'
            DestinationPath = 'c:\choco'
            Ensure = "Present"    
        }
        File DacPacDir
        {
            Type = 'Directory'
            DestinationPath = 'c:\dacpac'
            Ensure = "Present"    
        }

        cChocoInstaller installChoco
        {
            InstallDir = "c:\choco"
            DependsOn = "[File]ChocoDir"
        }
        cChocoPackageInstaller SQLExpress 
        {
            Name = "mssqlservermanagementstudio2014express"
            DependsOn = "[cChocoInstaller]installChoco"
            Ensure = "Present"
        } 


        xRemoteFile DacPacPackage
        {  
             Uri             = "https://github.com/stuartshay/CoreDataStore/raw/master/data/SQLDataTier/NycLandmarks.dacpac"
             DestinationPath = "c:\dacpac\NycLandmarks.dacpac"
             DependsOn       = "[File]DacPacDir"
        } 
        xRemoteFile BacPacPackage
        {  
             Uri             = "https://github.com/stuartshay/CoreDataStore/raw/master/data/SQLDataTier/NycLandmarks.bacpac"
             DestinationPath = "c:\dacpac\NycLandmarks.bacpac"
             DependsOn       = "[File]DacPacDir"
        } 
    }
} 
