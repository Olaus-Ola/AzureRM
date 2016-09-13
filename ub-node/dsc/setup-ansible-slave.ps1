Configuration AnsibleControl
{     
    Import-DscResource -Module nx   
    
    Node ansible-slave {  

        nxPackage ssh  
        {  
            Ensure          = "Present"
            Name            = "ssh"
            PackageManager  = "apt"
        } 
   
    }

}