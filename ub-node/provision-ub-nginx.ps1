Login-AzureRMAccount
Set-Location C:\Users\sshay\Documents\GitHub\AzureRM\ub-node

$ResourceGroupName = 'AzureRM'
$VnetName = "AzureRmVNet"
$SubNetIndex = 2
$Location = 'East US 2'
$StorageAccountName = "azurestoragez1"


#Create MOF File
. ./dsc/setup-nginx-proxy.ps1
Webproxy -StorageAccountName $StorageAccountName -Output ./mof


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
    ContainerName = "nginx"
    PathToContent =".\config\nginx" 
};
. ..\util\upload-scripts.ps1 @UploadScripts


$i = 0
For ($i=0; $i -lt 1; $i++) {

    $VirtualMachine = @{
       ResourceGroupName = $ResourceGroupName
       Location = $Location
       StorageAccountName = $StorageAccountName
       VnetName = $VnetName
       SubnetIndex = $SubNetIndex
       VmName = "ub-nginx-proxy-$i"
       NicName = "ub-nginx-proxy-nic-$i"
       VmSize = "Standard_D1_v2"
       }

   .  .\..\base\build-ub.ps1 @VirtualMachine;

}


#Apply DSC Extension
$DSC = @{
    ResourceGroupName = $ResourceGroupName
    Location = $Location
    StorageAccountName = $StorageAccountName
    ContainerName = "mof"
    MOFfile = "localhost.mof"
    VmName = "ub-nginx-proxy-0"
    Platform = "Linux"
 }
..\util\Install-mof.ps1 @DSC


#  ********* Manual Step/Test Machine *************** 
# Manually Add IP and Login
# Verify and Run waagent on Host


 #Extract-Base Image
$BaseImage = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "vm-images"
    VmName = "ub-nginx-proxy-0"
    NicName ="ub-nginx-proxy-nic-0"
    VhdNamePrefix = "ub-nginx-2016-08-30"

 };

 .\extract-ub.ps1 @BaseImage 