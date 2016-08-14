Login-AzureRMAccount
Set-Location C:\Users\sshay\Documents\GitHub\AzureRM\win-node

$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
$VnetName = "AzureRmVNet"
$SubNetIndex = 2

$StorageAccountName = "azurestoragez1"


# Build Base Image 
$i = 1
For ($i=1; $i -lt 2; $i++) {
  $VitualMachine = @{
       ResourceGroupName = $ResourceGroupName;
       Location = $Location;
       StorageAccountName = $StorageAccountName;
       VnetName = $VnetName;
       SubnetIndex = $SubnetIndex;
       VmName = "win-server-$i";
       NicName = "win-server-nic-$i";
       VmSize = "Standard_D1_v2";
       };

    . .\..\base\build-win-server.ps1 @VitualMachine;

}


#Apply DSC Configuration
$i = 1
For ($i=1; $i -lt 2; $i++) {

 Set-AzureRmVMDSCExtension -ResourceGroupName $resourceGroup -VMName  win-server-$i -Version '2.15' `
                              -ArchiveBlobName "win-web-server-dsc.ps1.zip" `
                              -ArchiveStorageAccountName $storageAccountName `
                              -ConfigurationName "WebApp"

}

