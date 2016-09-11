Login-AzureRMAccount
Set-Location C:\Users\sshay\Documents\GitHub\AzureRM\win-node

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
       VmName = "win-sql-$i";
       NicName = "win-sql-nic-$i";
       VmSize = "Standard_D2_v2";
       };

    . .\..\base\build-win-server.ps1 @VirtualMachine;
}



#Install Secondary Data Disk
$i = 0
    $DataDisk  = @{
       ResourceGroupName = $ResourceGroupName;
       Location = $Location;
       StorageAccountName = $StorageAccountName;
       VmName = "win-sql-$i";
       DiskName = "win-sql-$i-data01" 
       };
   ..\util\add-data-disk.ps1 @DataDisk 


#region Publish DSC Image 

#Local File System

Publish-AzureRmVMDscConfiguration -ConfigurationPath .\dsc\setup-sql-prerequisite.ps1 -OutputArchivePath "mof\setup-sql-prerequisite.ps1.zip" -Force 

<#Apply DSC Configuration
  
   FILE TO UPLOAD: setup-sql-prerequisite.ps1
   Module-Qualified Name of Configuration - setup-sql-prerequisite.ps1\payload
   Configuration Arguments 
   nodename=localhost,storageAccountName=azurestoragez1,sqlVersion=2016

   Version = 2.20 (Latest)
   Allow minor Version updates true
#>


# Azure Blob Storage 
Publish-AzureRmVMDscConfiguration -ConfigurationPath .\dsc\setup-sql-prerequisite.ps1 `
                            -ResourceGroupName $ResourceGroupName -StorageAccountName $storageAccountName -Force 


$i = 0
For ($i=0; $i -lt 1; $i++) {

 $configurationArguments = @{"nodename"="localhost"; "storageAccountName"="$StorageAccountName"; "sqlVersion" = "2016";}
 $achiveblobName = 'setup-sql-prerequisite.ps1.zip';


Set-AzureRmVMDscExtension -ResourceGroupName $ResourceGroupName -VMName win-sql-$i -ArchiveBlobName $achiveblobName `
    -ArchiveStorageAccountName $StorageAccountName -ConfigurationName "Payload" `
    -ConfigurationArgument $configurationArguments -Version 2.20 -Force

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
    VmName = "win-sql-0"
    NicName ="win-sql-nic-0"
    VhdNamePrefix = "win-sql-2016-2016-09-02"

 };

 .\extract-win.ps1 @BaseImage 

