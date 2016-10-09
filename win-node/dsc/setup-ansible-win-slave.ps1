Configuration Payload
{
    
    Import-DscResource -ModuleName @{ModuleName="xPSDesiredStateConfiguration"; ModuleVersion="3.13.0.0"}

    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        File SetupDir
        {
            Type = 'Directory'
            DestinationPath = 'c:\Setup'
            Ensure = "Present"    
        }

        xRemoteFile AnsibleRemotingScriptDownload
        {  
            Uri             = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
            DestinationPath = 'c:\Setup\ConfigureRemotingForAnsible.ps1'
            DependsOn       = "[File]SetupDir"
            MatchSource     = $false
        }
        
        
        Script AnsibleRemotingInstall
        {   
    
            TestScript = 
            { 
                Test-Path "c:\Setup\ConfigureRemotingForAnsible.ps1"
            }
            SetScript = 
            {
                & c:\Setup\ConfigureRemotingForAnsible.ps1
            }  
            GetScript =
            {
               # Do Nothing
            }  
            
                        
            DependsOn  = "[xRemoteFile]AnsibleRemotingScriptDownload"          
        }

                            
    }

}