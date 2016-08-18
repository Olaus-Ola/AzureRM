Configuration WebProxy
{     
    Import-DscResource -Module nx   
    
    Node localhost {  

        nxPackage Nginx  
        {  
            Ensure          = "Present"
            Name            = "nginx"
            PackageManager  = "apt"
        } 
    }

}

#build MOF:
WebProxy -OutputPath "../mof"