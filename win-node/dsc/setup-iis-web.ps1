Configuration WebSite
{ 
    param ( 
        [string[]]$NodeName = 'localhost'
    ) 

    Import-DscResource -Module xWebAdministration     
    Import-DSCResource -Module xPSDesiredStateConfiguration 
    Import-DSCResource -Module xNetworking 

    Node $NodeName { 

	  WindowsFeature IIS 
	  { 
	        Name = "Web-Server"
            Ensure = "Present"
      }

      WindowsFeature IISManagement  
      {  
            Ensure          = "Present"
            Name            = "Web-Mgmt-Console"
            DependsOn       = "[WindowsFeature]IIS"
      } 


      xWebsite DefaultSite   
      {  
            Ensure          = "Present"
            Name            = "Default Web Site"
            State           = "Stopped"
            PhysicalPath    = "C:\inetpub\wwwroot" 
            DependsOn       = "[WindowsFeature]IIS"
      } 


      xRemoteFile DotNetCoreWindowsHosting
      {  
            Uri             = "https://go.microsoft.com/fwlink/?LinkId=817246"
            DestinationPath = "C:\setup\DotNetCore.1.0.0-WindowsHosting.exe"
      } 


      xRemoteFile DotNetCoreSDK
      {  
            Uri             = "https://go.microsoft.com/fwlink/?LinkID=809122"
            DestinationPath = "C:\setup\DotNetCore.1.0.0-SDK.Preview2-x64.exe"
      } 


      xRemoteFile AppVeyorDeploymentAgent
      {  
            Uri             = "https://www.appveyor.com/downloads/deployment-agent/latest/AppveyorDeploymentAgent.msi"
            DestinationPath = "C:\setup\AppveyorDeploymentAgent.v3.12.0.msi"
      } 


      Package InstallDotNetCoreWindowsHosting
      {
           Ensure = "Present"
           Path = "C:\setup\DotNetCore.1.0.0-WindowsHosting.exe"
           Arguments = "/q /norestart"
           Name = "DotNetCore"
           ProductId = "4ADC4F4A-2D55-442A-8655-FBF619F94A69"
           DependsOn = "[xRemoteFile]DotNetCoreWindowsHosting"
    }

      xRemoteFile TestWebSite
      {  
            Uri             = "https://github.com/stuartshay/AzureRM/raw/master/assets/webapp.zip"
            DestinationPath = "C:\website\webapp.zip"
      } 

      Archive UnpackWebsite 
      {
            Ensure          = "Present" 
            Path            = "C:\website\webapp.zip"
            Destination     = "C:\website\"
      }


      xWebAppPool WebAppAppPool   
      {  
            Ensure          = "Present"  
            Name            = "web-app" 
            State           = "Started"
            managedRuntimeVersion = ""
      } 


      xFirewall Http8080
      {
            Name         = "Htpp-8080"
            DisplayName  = "Htpp-8080"
            Ensure       = "Present"
            Action       = "Allow"
            Direction    = "Inbound"
            LocalPort    = ("8080")
            Protocol     = "TCP"
      } 



    } 

}