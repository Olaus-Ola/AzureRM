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

# Add Tags 
$Tags = @{"environment" = "production"; "os" = "windows2016"; "group" = "server"; "window" = "win-container-0" }
Set-AzureRmResource -ResourceGroupName $ResourceGroupName -Name "win-container-0" -ResourceType "Microsoft.Compute/VirtualMachines" -Tag $Tags -Force



#region Publish DSC Image 

#Local File System

Publish-AzureRmVMDscConfiguration -ConfigurationPath .\dsc\setup-ansible-win-slave.ps1 -OutputArchivePath "mof\setup-ansible-win-slave.ps1.zip" -Force 


<#Apply DSC Configuration
  
   FILE TO UPLOAD: setup-ansible-win-slave.ps1.zip
   Module-Qualified Name of Configuration - setup-ansible-win-slave.ps1\payload

   Version = 2.20 (Latest)
   Allow minor Version updates true
#>


# Azure Blob Storage 
Publish-AzureRmVMDscConfiguration -ConfigurationPath .\dsc\setup-ansible-win-slave.ps1 `
                            -ResourceGroupName $ResourceGroupName -StorageAccountName $storageAccountName -Force 

$i = 0
For ($i=0; $i -lt 1; $i++) {

 ##$configurationArguments = @{"nodename"="localhost";}
 $achiveblobName = 'setup-ansible-win-slave.ps1.zip';


Set-AzureRmVMDscExtension -ResourceGroupName $ResourceGroupName -VMName win-container-$i -ArchiveBlobName $achiveblobName `
    -ArchiveStorageAccountName $StorageAccountName -ConfigurationName "payload" `
    -Version 2.20 -Force
     #-ConfigurationArgument $configurationArguments `
    
}

#endregion




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

