Login-AzureRMAccount
Set-Location C:\Users\sshay\Documents\GitHub\AzureRM\ub-node


$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
$VnetName = "AzureRmVNet"
$SubNetIndex = 2

$StorageAccountName = "azurestoragez1"

#Create MOF File
. ./dsc/setup-ansible-control.ps1
AnsibleControl  -Output ./mof


# Upload MOF File
$UploadMof = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "mof"
      File = "./mof/localhost.mof"
 };
. ..\util\upload-mof.ps1 @UploadMof 


#Upload Scripts
$UploadScripts = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "ansible"
    PathToContent =".\config\ansible" 
};
. ..\util\upload-scripts.ps1 @UploadScripts


#Build VM
$i = 0
For ($i=0; $i -lt 1; $i++) {

    $VirtualMachine = @{
       ResourceGroupName = $ResourceGroupName;
       Location = $Location;
       StorageAccountName = $StorageAccountName;
       VnetName = $VnetName;  
       SubnetIndex = $SubNetIndex;
       VmName = "ub-ansible-$i";
       NicName = "ub-ansible-nic-$i"
       VmSize = "Standard_D1_v2"
       };

   .  .\..\base\build-ub.ps1 @VirtualMachine;

}


#Apply DSC Extension
$DSC = @{
    ResourceGroupName = $ResourceGroupName
    Location = $Location
    StorageAccountName = $StorageAccountName
    ContainerName = "mof"
    MOFfile = "localhost.mof"
    VmName = "ub-ansible-0"
 }
 .\Install-mof.ps1 @DSC



#  ********* Manual Step/Test Machine *************** 
# Manually Add IP and Login
# Verify and Run waagent on Host >sudo waagent -deprovision+user

 #Extract-Base Image
$BaseImage = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "vm-images"
    VmName = "ub-ansible-0"
    NicName ="ub-ansible-nic-0"
    VhdNamePrefix = "ub-ansible-2016-08-31"

 };

 .\extract-ub.ps1 @BaseImage 





# Notes 
ub-ansible-0        -  192.168.3.5
ub-ansible-client-0 -  192.168.3.6



#Update Build
sudo apt-get update
sudo apt-get install
sudo apt-get upgrade

# Create SSH Keys - To Store in Azure Key Store
#SSH keys should be generated on the computer you wish to log in from

ssh-keygen -t rsa

ssh-agent bash
ssh-add ~/.ssh/id_rsa


# Ansible Install
#http://docs.ansible.com/ansible/intro_installation.html
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible


# Update Hosts 
sudo nano /etc/ansible/hosts

# 









