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

    } 

}