Configuration WebProxy
{     
    Import-DscResource -Module nx   
    
Param (
    [Parameter(Mandatory=$true)][string] $StorageAccountName
    )


    Node webproxy {  

        nxPackage Nginx  
        {  
            Ensure          = "Present"
            Name            = "nginx"
            PackageManager  = "apt"
        } 

        nxFile DefaultConf 
        {
            Ensure = "absent"
            DestinationPath = '/etc/nginx/sites-enabled/default'
            DependsOn = '[nxPackage]Nginx'
        }
        
        nxFile ProxyConf 
        {
            SourcePath = "https://$using:StorageAccountName.blob.core.windows.net/config/nginx.conf"
            DestinationPath = '/etc/nginx/sites-available/proxy'
            DependsOn = '[nxPackage]Nginx'
        }  

        nxScript EnableProxy
        {
            DependsOn = '[nxFile]ProxyConf'
            
            GetScript = @' 
#!/bin/bash
ls /etc/nginx/sites-enabled/ | wc -l 
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

        nxService NginxStart
        {
            Name = "nginx"
            State = "Running"
            Enabled = $true
            Controller = "init"
            DependsOn = '[nxScript]EnableProxy'
        }
    }
}
