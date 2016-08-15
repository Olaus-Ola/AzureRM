## Azure Resource Manager 

###Prerequisites

Windows 8.1 and Below    
Windows Management Framework 5.0   
https://www.microsoft.com/en-us/download/details.aspx?id=50395


Azure PowerShell 1.0   
https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/

Powershell ISE Project Explorer    
https://gallery.technet.microsoft.com/Powershell-ISE-Explorer-bfc92307

The Powershell Execution Policy is required to be set before adding the plugin

````
  Set-ExecutionPolicy  Unrestricted
````
###Tools

Microsoft Azure Storage Explorer   
http://storageexplorer.com/    

Multi-Tabbed PuTTY   
http://ttyplus.com/multi-tabbed-putty/

###Setup 

####resourceGroup.ps1

This Script will setup the Resource Group and Networking Foundation.   

|   			      |   			        |
|---------------|-----------------|
|Resource Group |AzureRM          |
|Network        |192.168.0.0/16   |


##### Subnets
|Subnet 		       | Network Range   | Index |
|:-----------------|-----------------|:-----:|
|FrontEnd          |192.168.1.0/24   |0      |
|BackEnd           |192.168.2.0/24   |1      |
|Client Network    |192.168.3.0/24   |2      |

####storage.ps1   
Create the Storage Account   
Note: A Storage must be FQDN and unique in Azure   
(Update the existing account name in the script)        

###Creating a Base Image

It is recomended to create a standard base image of your OS and Applications, this will provide a base line configuration and a good starting point when expanding your azure network. 


|OS	               | Sku                |
|:-----------------|--------------------|
|UbuntuServer      |16.04.0-LTS         |
|Windows 10        |10-Enterprise-N     |
|WindowsServer     |2012-R2-Datacenter  |


### DSC Extentions 

In a Powershell Admin Console add the necessary DSC Modules

````
Install-Module -Name xNetworking, xPSDesiredStateConfiguration, xWebAdministration
Update-Module
````

### Generalize and Extract Image

After you are satisfied with the Configuration of the VM, the Image can be Generalized and used as base image for building additional VM’s     

Verify and test the Image 

Generalize 

Linux    
````
sudo waagent -deprovision+user
````


Windows     
````
  cd %windir%\system32\sysprep
  sysprep /generalize /shutdown /oobe
````





