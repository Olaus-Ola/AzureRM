Configuration AnsibleControl
{     
    Import-DscResource -Module nx   
    
    Node ansiblecontrol {  

        nxPackage Nginx  
        {  
            Ensure          = "Present"
            Name            = "httpd"
            PackageManager  = "apt"
        } 
    }

}
