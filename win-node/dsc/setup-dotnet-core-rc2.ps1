Configuration Payload
{

Param ( [string] $nodeName )

Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DscResource -ModuleName @{ModuleName="xPSDesiredStateConfiguration"; ModuleVersion="3.0.3.4"}
Import-DscResource -ModuleName @{ModuleName="xWebAdministration"; ModuleVersion="1.13.0.0"}

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

    xRemoteFile Payload {
        Uri             = "https://github.com/stuartshay/AzureRM/raw/master/assets/webapp.zip" 
        DestinationPath = "C:\WindowsAzure\website.zip" 
    }

    xRemoteFile InstallDotNetCoreWindowsHosting {
        Uri             = "https://go.microsoft.com/fwlink/?LinkId=817246" 
        DestinationPath = "C:\WindowsAzure\InstallDotNetCoreWindowsHosting" 
    }

    xRemoteFile DotNetCoreSDK {
        Uri             = "https://go.microsoft.com/fwlink/?LinkID=809122" 
        DestinationPath = "C:\WindowsAzure\DotNetCore.1.0.0-SDK.Preview2-x64.exe"
    }

        Archive WebAppExtract
        {              
            Path = "C:\WindowsAzure\website.zip"
            Destination = "c:\inetpub"
            DependsOn = "[xRemoteFile]Payload"            
        }

    Package InstallDotNetCoreWindowsHosting
    {
           Ensure = "Present"
           Path = "C:\WindowsAzure\DotNetCore.1.0.0-WindowsHosting.exe"
           Arguments = "/q /norestart"
           Name = "DotNetCore"
           ProductId = "4ADC4F4A-2D55-442A-8655-FBF619F94A69"
           DependsOn = "[xRemoteFile]InstallDotNetCoreWindowsHosting"
    }
    Package DotNetCoreSDK
    {
           Ensure = "Present"
           Path = "C:\WindowsAzure\DotNetSDK.exe"
           Arguments = "/q /norestart"
           Name = "DotNetSDK"
           ProductId = "E7195A54-693B-4ECF-A7F5-1972A720068B"
           DependsOn = "[xRemoteFile]DotNetCore.1.0.0-SDK.Preview2-x64.exe"
    }

	xWebsite DefaultSite   
      {  
            Ensure          = "Present"
            Name            = "Default Web Site"
            State           = "Stopped"
            PhysicalPath    = "C:\inetpub\wwwroot" 
            DependsOn       = "[WindowsFeature]WebServerRole"
      }
	xWebAppPool WebAppAppPool   
      {  
            Ensure          = "Present"  
            Name            = "web-app" 
            State           = "Started"
            managedRuntimeVersion = ""
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
  }
}

payload -nodename localhost
