Configuration AnsibleSlave
{     
    Import-DscResource -Module nx   
    
    Node ansible-slave {  

        nxPackage ssh  
        {  
            Ensure          = "Present"
            Name            = "ssh"
            PackageManager  = "apt"
        } 
		nxFileLine nopass
        {
            FilePath = "/etc/sudoers"
            ContainsLine = 'ansible ALL=(ALL) NOPASSWD:ALL'
         }
    }

}