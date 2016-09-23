<#
 Ansible Master Base Image 
#>

Login-AzureRMAccount

$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
$VnetName = "AzureRmVNet"
$SubNetIndex = 2

$StorageAccountName = "azurestoragez1"

#Create MOF File
. ./dsc/setup-ansible-control.ps1
AnsibleControl  -Output ./mof

#Upload MOF File
$UploadMof = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "mof"
      File = "./mof/ansible-master.mof"
 };
. ..\util\upload-mof.ps1 @UploadMof 


#Build VM
$i = 37
For ($i=37; $i -lt 40; $i++) {

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
    MOFfile = "ansible-master.mof"
    VmName = "ub-ansible-37"
    Platform = "Linux"
 };
  .  .\..\util\install-mof.ps1 @DSC
