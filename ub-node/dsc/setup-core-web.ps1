Configuration CoreWeb
{     
    
Import-DscResource -Module nx 

    Node CoreWeb {  

        nxPackage GitHub  
        {  
            Ensure          = "Present"
            Name            = "git"
            PackageManager  = "apt"
        } 


        nxScript Install-NetCore
        {
       
            GetScript = @' 
sudo sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893
sudo apt-get update
'@

            TestScript = @'
#!/bin/bash
exit 0
'@

            SetScript = @'
#!/bin/bash
exit 0
'@

        }
        
     }

}