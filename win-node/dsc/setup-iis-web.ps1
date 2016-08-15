Configuration WebSite
{ 
    param ( 
        [string[]]$NodeName = 'localhost'
    ) 

    Import-DscResource -Module xWebAdministration, PSDesiredStateConfiguration

    Node $NodeName { 

	  WindowsFeature InstallWebServer 
	  { 
	       Name = "Web-Server"
           Ensure = "Present"
      }
    } 

}