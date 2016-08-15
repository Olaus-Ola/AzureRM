Configuration WebSite
{ 
    param ( 
        [string[]]$NodeName = 'localhost'
    ) 

    Import-DscResource -Module xWebAdministration     
    Import-DSCResource -Module xPSDesiredStateConfiguration 
    Import-DSCResource -Module xNetworking 

    Node $NodeName { 

	  WindowsFeature InstallWebServer 
	  { 
	        Name = "Web-Server"
            Ensure = "Present"
      }

      xRemoteFile DotNetCoreWindowsHosting
      {  
        Uri             = "https://go.microsoft.com/fwlink/?LinkId=817246"
        DestinationPath = "C:\setup\DotNetCore.1.0.0-WindowsHosting.exe"
      } 


      xRemoteFile DotNetCoreSDK
      {  
        Uri             = "https://go.microsoft.com/fwlink/?LinkID=809122"
        DestinationPath = "C:\setup\DotNetCore.1.0.0-SDK.Preview2-x64"
      } 




    } 

}