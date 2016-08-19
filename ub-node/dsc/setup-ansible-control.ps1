Configuration AnsibleControl
{     
    Import-DscResource -Module nx   
    
    Node localhost {  

        nxPackage Nginx  
        {  
            Ensure          = "Present"
            Name            = "httpd"
            PackageManager  = "apt"
        } 
    }

}

#build MOF:
WebProxy -OutputPath "../mof"