Login-AzureRMAccount
Set-Location C:\Users\sshay\Documents\GitHub\AzureRM\ub-node


$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
$VnetName = "AzureRmVNet"
$SubNetIndex = 2

$StorageAccountName = "azurestoragez1"


#Create MOF File
. ./dsc/setup-core-web.ps1 
CoreWeb -Output ./mof


# Upload MOF File
$UploadMof = @{

    ResourceGroupName = $ResourceGroupName
    Location = $Location
    StorageAccountName = $StorageAccountName
    ContainerName = "mof"
    File = "./mof/coreweb.mof"
 }
. ..\util\upload-mof.ps1 @UploadMof 


#Upload Scripts
$UploadScripts = @{

    ResourceGroupName = $ResourceGroupName
    Location = $Location
    StorageAccountName = $StorageAccountName
    ContainerName = "core-web"
    PathToContent =".\config\coreweb" 
}
. ..\util\upload-scripts.ps1 @UploadScripts





$i = 1
For ($i=1; $i -lt 2; $i++) {

    $VirtualMachine = @{
       ResourceGroupName = $ResourceGroupName;
       Location = $Location;
       StorageAccountName = $StorageAccountName;
       VnetName = $VnetName;  
       SubnetIndex = $SubNetIndex;
       VmName = "ub-coreweb-$i";
       NicName = "ub-coreweb-nic-$i"
       VmSize = "Standard_D1_v2"
       };

   .  .\..\base\build-ub.ps1 @VirtualMachine;

}

