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
    File = "./mof/ansiblecontrol.mof"
 };
. ..\util\upload-mof.ps1 @UploadMof 


$i = 5
For ($i=5; $i -lt 7; $i++) {

    $VitualMachine = @{
       ResourceGroupName = $ResourceGroupName;
       Location = $Location;
       StorageAccountName = $StorageAccountName;
       VnetName = $VnetName;  
       SubnetIndex = $SubNetIndex;
       VmName = "ub-ansible-$i";
       NicName = "ub-ansible-nic-$i"
       VmSize = "Standard_D1_v2"
       };

   .  .\..\base\build-ub.ps1 @VitualMachine;

}







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









