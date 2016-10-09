Login-AzureRMAccount

$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
$VnetName = "AzureRmVNet"
$SubNetIndex = 2

$StorageAccountName = "azurestoragez1"

# Build Base Image 
$i = 0
For ($i=0; $i -lt 1; $i++) {
  
  $VirtualMachine  = @{
       ResourceGroupName = $ResourceGroupName;
       Location = $Location;
       StorageAccountName = $StorageAccountName;
       VnetName = $VnetName;
       SubnetIndex = $SubnetIndex;
       VmName = "win-container-$i";
       NicName = "win-container-nic-$i";
       VmSize = "Standard_D2_v2";
       };

    . .\..\base\build-win-datacenter.ps1 @VirtualMachine;
}


<#

Extract-Base Image & Generalize

 Manually Log into machine and Test Functionality
 cd %windir%\system32\sysprep
 sysprep /generalize /shutdown /oobe

#>


$BaseImage = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "vm-images"
    VmName = "win-container-0"
    NicName ="win-container-nic-0"
    VhdNamePrefix = "win-container-2016-10-09"

 };

 .\extract-win.ps1 @BaseImage 

