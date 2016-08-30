Configuration CoreWeb
{     
    
    Import-DscResource -Module nx

    Node localhost {  

        nxPackage GitHub  
        {  
            Ensure          = "Present"
            Name            = "git"
            PackageManager  = "apt"
        } 

        nxPackage Tree  
        {  
            Ensure          = "Present"
            Name            = "tree"
            PackageManager  = "apt"
        } 


        nxScript Install-NetCore
        {
       
            GetScript = @' 
#!/bin/bash
exit 0
'@

            TestScript = @'
#!/bin/bash
exit 1
'@

            SetScript = @'
#!/bin/bash
sudo sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893
sudo apt-get update
'@

        }
    }
}