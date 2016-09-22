<#
 Ansible Slave/Client Base Image 
#>

Login-AzureRMAccount

$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
$VnetName = "AzureRmVNet"
$SubNetIndex = 2

$StorageAccountName = "azurestoragez1"


#Create MOF File
. ./dsc/setup-ansible-slave.ps1
AnsibleSlave  -Output ./mof


#Upload MOF File
$UploadMof = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "mof"
      File = "./mof/ansible-slave.mof"
 };
. ..\util\upload-mof.ps1 @UploadMof 


#Build VM
$i = 0
For ($i=0; $i -lt 1; $i++) {

    $VirtualMachine = @{
       ResourceGroupName = $ResourceGroupName;
       Location = $Location;
       StorageAccountName = $StorageAccountName;
       VnetName = $VnetName;  
       SubnetIndex = $SubNetIndex;
       VmName = "ub-slave-$i";
       NicName = "ub-slave-nic-$i"
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
    VmName = "ub-slave-0"
    Platform = "Linux"
 };
  .  .\..\util\install-mof.ps1 @DSC
