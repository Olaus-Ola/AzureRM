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
    File = "./mof/localhost.mof"
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

#Build VM
$i = 0
For ($i=0; $i -lt 1; $i++) {

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

#Apply DSC Extension
$DSC = @{
    ResourceGroupName = $ResourceGroupName
    Location = $Location
    StorageAccountName = $StorageAccountName
    ContainerName = "mof"
    MOFfile = "localhost.mof"
    VmName = "ub-coreweb-0"
 }
 .\Install-mof.ps1 @DSC



#  ********* Manual Step/Test Machine *************** 
# Manually Add IP and Login
# Verify and Run waagent on Host >sudo waagent -deprovision+user

 #Extract-Base Image
$BaseImage = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "vm-images"
    VmName = "ub-coreweb-0"
    NicName ="ub-coreweb-nic-0"
    VhdNamePrefix = "ub-coreweb-2016-08-30"

 };

 .\extract-ub.ps1 @BaseImage 