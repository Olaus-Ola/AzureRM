Configuration AnsibleControl
{     
    Import-DscResource -Module nx   
    
    Node ansible-master {  

        nxPackage ssh  
        {  
            Ensure          = "Present"
            Name            = "ssh"
            PackageManager  = "apt"
        } 
		nxPackage sshpass  
        {  
            Ensure          = "Present"
            Name            = "sshpass"
            PackageManager  = "apt"
        } 
		nxPackage ansible  
        {  
            Ensure          = "Present"
            Name            = "ansible"
            PackageManager  = "apt"
        } 
		nxPackage git  
        {  
            Ensure          = "Present"
            Name            = "git"
            PackageManager  = "apt"			
        }

        nxFile requirements
        {
            SourcePath = "https://raw.githubusercontent.com/stuartshay/AzureRM/master/ub-ansible/config/requirements.txt"
            DestinationPath = "/tmp/requirements.txt"
            Type = "file"
        } 


		nxScript Get_ansible_playbook
        {
            DependsOn = '[nxPackage]git'
            
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
cd /etc/ansible/
git clone https://github.com/stuartshay/AnsiblePlaybooks.git
'@
        } 
		nxPackage libssl_dev  
        {  
            Ensure          = "Present"
            Name            = "libssl-dev"
            PackageManager  = "apt"			
        }
	    nxPackage pip  
        {  
            Ensure          = "Present"
            Name            = "python-pip"
            PackageManager  = "apt"			
        }
		nxScript azure_python_sdk
        {
            DependsOn = '[nxPackage]pip'
            
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
pip install --upgrade pip
sudo pip install -r /tmp/requirements.txt
'@
        } 
    }

}