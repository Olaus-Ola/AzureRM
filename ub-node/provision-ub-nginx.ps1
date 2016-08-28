Login-AzureRMAccount
Set-Location C:\Users\sshay\Documents\GitHub\AzureRM\ub-node

$ResourceGroupName = 'AzureRM'
$VnetName = "AzureRmVNet"
$SubNetIndex = 2

$StorageAccountName = "azurestoragez1"

#Create MOF File
. ./dsc/setup-nginx-proxy.ps1
Webproxy -StorageAccountName $StorageAccountName -Output ./mof


# Upload MOF File
$UploadMof = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "mof"
    File = "./mof/webproxy.mof"
 };
. ..\util\upload-mof.ps1 @UploadMof 



#Upload Scripts
$UploadScripts = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "nginx"
    PathToContent =".\config\nginx" 
};
. ..\util\upload-scripts.ps1 @UploadScripts


$i = 1
For ($i=1; $i -lt 2; $i++) {

    $VirtualMachine = @{
       ResourceGroupName = $ResourceGroupName;
       Location = $Location;
       StorageAccountName = $StorageAccountName;
       VnetName = $VnetName;  
       SubnetIndex = $SubNetIndex;
       VmName = "ub-nginx-proxy-$i";
       NicName = "ub-nginx-proxy-nic-$i"
       VmSize = "Standard_D1_v2"
       };

   .  .\..\base\build-ub.ps1 @VirtualMachine;

}



#Apply DSC Extension
#Use Basic ansiblecontrol.mof as Test
$DSC = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "mof"
    MOFfile = "ansiblecontrol.mof"
    VmName = "ub-nginx-proxy-1"
 };

 .\Install-mof.ps1 @DSC


#  ********* Manual Step/Test Machine *************** 
# Verify and Run waagent on Host
# Manually Add IP and Login

 #Extract-Base Image
$BaseImage = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "vm-images"
    VmName = "ub-nginx-proxy-1"
    NicName ="ub-nginx-proxy-nic-1"
    VhdNamePrefix = "ub-nginx-2016-08-28"

 };

 .\extract-ub.ps1 @BaseImage 


