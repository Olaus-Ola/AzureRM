Login-AzureRMAccount
Set-Location C:\Users\sshay\Documents\GitHub\AzureRM\win-node


$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
$VnetName = "AzureRmVNet"
$SubNetIndex = 2

$StorageAccountName = "azurestoragez1"


#region Publish DSC Image 
  
  # Azure Blob Storage 
  Publish-AzureRmVMDscConfiguration -ConfigurationPath .\dsc\setup-sql-2014express.ps1 `
                                    -ResourceGroupName $ResourceGroupName -StorageAccountName $storageAccountName -Force 


  #Local File System
  Publish-AzureRmVMDscConfiguration -ConfigurationPath .\dsc\setup-sql-2014express.ps1 -OutputArchivePath "mof\setup-sql-2014express.ps1.zip" -Force 
  
#endregion


# Build Base Image 
$i = 10
For ($i=10; $i -lt 13; $i++) {
  
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




$i = 21
#Install Secondary Data Disk
    $DataDisk  = @{
       ResourceGroupName = $ResourceGroupName;
       Location = $Location;
       StorageAccountName = $StorageAccountName;
       VmName = "win-sql-$i";
       DiskName = "1A"
       };
   ..\util\add-data-disk.ps1 @DataDisk 










#Apply DSC Configuration
  # FILE TO UPLOAD: setup-sql-2014express.ps1.zip
  # Module-Qualified Name of Configuration - setup-sql-2014express.ps1\payload
  # Configuration Arguments - nodeName=localhost
  # Versión = 2.20 (Latest)
  # Allow minor versión updates true




$i = 0
For ($i=0; $i -lt 1; $i++) {

 $achiveblobName = 'setup-iis-web.zip';

 Set-AzureRmVMDSCExtension -ResourceGroupName $ResourceGroupName -VMName  win-sql-nic-$i -Version '2.8' `
                              -ArchiveBlobName $achiveblobName `
                              -ArchiveStorageAccountName $StorageAccountName `
                              -ConfigurationName "ConfigureWeb" -AutoUpdate

}


#Extract-Base Image & Generalize

# Manually Log into machine and Test Functionality
# cd %windir%\system32\sysprep
# sysprep /generalize /shutdown /oobe


$BaseImage = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "vm-images"
    VmName = "win-server-0"
    NicName ="win-server-nic-0"
    VhdNamePrefix = "win-server-coreweb-2016-08-30"

 };

 .\extract-win.ps1 @BaseImage 

