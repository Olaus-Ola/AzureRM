Login-AzureRMAccount
Set-Location C:\Users\sshay\Documents\GitHub\AzureRM\win-node


$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
$VnetName = "AzureRmVNet"
$SubNetIndex = 2

$StorageAccountName = "azurestoragez1"


#region Publish DSC Image 
  
  # Azure Blob Storage 
  Publish-AzureRmVMDscConfiguration -ConfigurationPath .\dsc\setup-iis-web.ps1 `
                                    -ResourceGroupName $ResourceGroupName -StorageAccountName $storageAccountName -Force 


  #Local File System
  # FILE TO UPLOAD: setup-iis-web.ps1.zip
  # Module-Qualified Name of Configuration - setup-iis-web.ps1\payload
  # Configuration Arguments - nodeName=localhost
  # Versión = 2.20 (Latest)
  # Allow minor versión updates true

  Publish-AzureRmVMDscConfiguration -ConfigurationPath .\dsc\setup-iis-web.ps1 -OutputArchivePath ".\setup-iis-web.ps1.zip" -Force 
  
#endregion


# Build Base Image 
$i = 0
For ($i=0; $i -lt 1; $i++) {
  
  $VirtualMachine  = @{
       ResourceGroupName = $ResourceGroupName;
       Location = $Location;
       StorageAccountName = $StorageAccountName;
       VnetName = $VnetName;
       SubnetIndex = $SubnetIndex;
       VmName = "win-server-$i";
       NicName = "win-server-nic-$i";
       VmSize = "Standard_D2_v2";
       };

    . .\..\base\build-win-server.ps1 @VirtualMachine;
}



#Apply DSC Configuration
$i = 0
For ($i=0; $i -lt 1; $i++) {

 #Need to Fix Parameters Below

 $achiveblobName = 'setup-iis-web.zip';

 Set-AzureRmVMDSCExtension -ResourceGroupName $ResourceGroupName -VMName  win-server-$i -Version '2.8' `
                              -ArchiveBlobName $achiveblobName `
                              -ArchiveStorageAccountName $StorageAccountName `
                              -ConfigurationName "ConfigureWeb" -AutoUpdate

}





