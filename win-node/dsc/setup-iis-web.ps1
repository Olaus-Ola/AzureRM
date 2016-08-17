Configuration Payload
{

Param ( [string] $nodeName )

Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DscResource -ModuleName xPSDesiredStateConfiguration
Import-DscResource -ModuleName xWebAdministration
Import-DscResource -ModuleName xNetworking

Node $nodeName
  {

    LocalConfigurationManager 
    { 
        # This is false by default
        RebootNodeIfNeeded = $true
    } 

        WindowsFeature WebServerRole
        {
            Name = "Web-Server"
            Ensure = "Present"
        }

        WindowsFeature WebManagementConsole
        {
            Name = "Web-Mgmt-Console"
            Ensure = "Present"
        }

        xRemoteFile Payload
        {
            Uri             = "https://github.com/stuartshay/AzureRM/raw/master/assets/webapp.zip" 
            DestinationPath = "C:\Setup\website.zip" 
        }

        xRemoteFile InstallDotNetCoreWindowsHosting
        {
            Uri             = "https://go.microsoft.com/fwlink/?LinkId=817246" 
            DestinationPath = "C:\Setup\InstallDotNetCoreWindowsHosting.exe" 
        }

        xRemoteFile AppVeyorDeploymentAgent
        {  
             Uri             = "https://www.appveyor.com/downloads/deployment-agent/latest/AppveyorDeploymentAgent.msi"
             DestinationPath = "C:\Setup\AppveyorDeploymentAgent.v3.12.0.msi"
        } 

        Archive WebAppExtract
        {              
             Path = "C:\Setup\website.zip"
             Destination = "C:\inetpub\"
             DependsOn = "[xRemoteFile]Payload"            
        }

        Package InstallDotNetCoreWindowsHosting
        {
               Ensure = "Present"
               Path = "C:\Setup\InstallDotNetCoreWindowsHosting.exe"
               Arguments = "/q /norestart"
               Name = "DotNetCore"
               ProductId = "4ADC4F4A-2D55-442A-8655-FBF619F94A69"
               DependsOn = "[xRemoteFile]InstallDotNetCoreWindowsHosting"
        }

	xWebAppPool WebAppAppPool   
        {  
                Ensure          = "Present"  
                Name            = "web-app" 
                State           = "Started"
                managedRuntimeVersion = ""
                DependsOn       = "[WindowsFeature]WebServerRole"
        }  

	xWebsite WebAppWebSite   
        {  
                Ensure          = "Present"  
                Name            = "web-app" 
                State           = "Started"
                PhysicalPath    = "C:\inetpub\webapp\wwwroot"
                ApplicationPool = "web-app"
                BindingInfo = MSFT_xWebBindingInformation
                        {
                            Port = '8080'
                            IPAddress = '*'
                            Protocol = 'HTTP'
                        }
                DependsOn = "[xWebAppPool]WebAppAppPool"
        }

        Script iisReset
        {
            TestScript =  { $false }
            SetScript =  { iisreset }
            GetScript = {@{Result = 'Will perform "iisreset" if invoked'}}
            DependsOn =  @('[xWebsite]WebAppWebSite', '[xWebAppPool]WebAppAppPool')

        }

        xWebsite DefaultSite   
        {  
                Ensure          = "Present"
                Name            = "Default Web Site"
                State           = "Stopped"
                PhysicalPath    = "C:\inetpub\wwwroot" 
                DependsOn       = "[Script]iisReset"
        }
    }
}
