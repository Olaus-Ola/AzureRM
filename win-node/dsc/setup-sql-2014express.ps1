Configuration Payload
{
    
    Param (
    [Parameter(Mandatory=$false)][string] $nodeName
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName @{ModuleName="cChoco"; ModuleVersion="2.1.1.54"}
    Import-DscResource -ModuleName @{ModuleName="xDatabase"; ModuleVersion="1.4.0.0"}

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


        cChocoInstaller InstallChoco
        {
            InstallDir = "c:\choco"
            DependsOn = "[File]ChocoDir"
        }


        cChocoPackageInstaller installGit
        {
         Name = "git.install"
         DependsOn = "[cChocoInstaller]InstallChoco"
        }


        File SetupDir
        {
            Type = 'Directory'
            DestinationPath = 'c:\Setup'
            Ensure = "Present"    
        }


        
         
    }
} 
