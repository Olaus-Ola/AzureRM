Configuration CoreWeb
{     
    
Import-DscResource -Module nx 

    Node webproxy {  

        nxPackage GitHub  
        {  
            Ensure          = "Present"
            Name            = "git"
            PackageManager  = "apt"
        } 


        nxScript Install-NetCore
        {
       
            GetScript = @' 
sudo sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ trusty main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893
sudo apt-get update

sudo apt-get install dotnet-dev-1.0.0-preview2-003121
'@

            TestScript = @'
#!/bin/bash
if [ -e "/etc/nginx/sites-enabled/proxy" ]
then
    exit 0
else 
    exit 1
fi
'@

            SetScript = @'
#!/bin/bash
ln -s /etc/nginx/sites-available/proxy /etc/nginx/sites-enabled
service nginx restart
'@

    }
}
}