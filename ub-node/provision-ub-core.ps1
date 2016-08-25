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

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "mof"
    File = "./mof/coreweb.mof"
 };
. ..\util\upload-mof.ps1 @UploadMof 





$i = 1
For ($i=1; $i -lt 2; $i++) {

    $VitualMachine = @{
       ResourceGroupName = $ResourceGroupName;
       Location = $Location;
       StorageAccountName = $StorageAccountName;
       VnetName = $VnetName;  
       SubnetIndex = $SubNetIndex;
       VmName = "ub-coreweb-$i";
       NicName = "ub-coreweb-nic-$i"
       VmSize = "Standard_D1_v2"
       };

   .  .\..\base\build-ub.ps1 @VitualMachine;

}

