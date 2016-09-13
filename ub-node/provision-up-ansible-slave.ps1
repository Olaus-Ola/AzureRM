#Login-AzureRMAccount
Set-Location C:\Users\Pari\Desktop\harpreet\Auto-deploy-docker-azure\ub-node


$ResourceGroupName = "ansible-resource"
$Location = "Canada Central"
$VnetName = "Ansible-network"
$SubNetIndex = 0

$StorageAccountName = "ansiblestorage635"

#Create MOF File
. ./dsc/setup-ansible-slave.ps1
AnsibleControl  -Output ./mof

#Upload MOF File
$UploadMof = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "mof"
      File = "./mof/ansible-slave.mof"
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
       VmName = "u-ansible-$i";
       NicName = "u-ansible-nic-$i"
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
    MOFfile = "ansible-slave.mof"
    VmName = "u-ansible-0"
 };
 .\Install-mof.ps1 @DSC



#  ********* Manual Step/Test Machine *************** 
# Manually Add IP and Login
# Verify and Run waagent on Host >sudo waagent -deprovision+user
# after the above command run the below code to remove the vm and extracting base image
  












