Configuration AnsibleControl
{     
    Import-DscResource -Module nx   
    
    Node localhost {  

        nxPackage Tree  
        {  
            Ensure          = "Present"
            Name            = "tree"
            PackageManager  = "apt"
        } 
    }

}
