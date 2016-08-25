Login-AzureRMAccount
Set-Location C:\Users\sshay\Documents\GitHub\AzureRM\ub-node

$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
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

.\upload-scripts.ps1 @UploadScripts





$i = 1
For ($i=9; $i -lt 10; $i++) {

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
$DSC = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "mof"
    MOFfile = "localhost.mof"
    VmName = "ub-nginx-proxy-9"
 };

 .\extension-ub.ps1 @DSC
