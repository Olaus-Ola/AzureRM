 ##Login-AzureRMAccount
Set-Location C:\Users\sshay\Documents\GitHub\AzureRM\ub-node

$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
$VnetName = "AzureRmVNet"
$SubNetIndex = 2

$StorageAccountName = "azurestoragez1"

#Create MOF File
./dsc/setup-nginx-proxy.ps1

# Upload MOF File
$Upload = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "mof"
    File = "mof\localhost.mof"
 };

.\upload.ps1 @Upload


#Create VM
$i = 9
For ($i=9; $i -lt 10; $i++) {

    $VitualMachine = @{
       ResourceGroupName = $ResourceGroupName;
       Location = $Location;
       StorageAccountName = $StorageAccountName;
       VnetName = $VnetName;  
       SubnetIndex = $SubNetIndex;
       VmName = "ub-ansible-client-$i";
       NicName = "ub-ansible-client-nic-$i"
       VmSize = "Standard_D1_v2"
       };

   .  .\..\base\build-ub.ps1 @VitualMachine;

}



#Apply DSC Extension
$DSC = @{

    ResourceGroupName = $ResourceGroupName;    
    Location = $Location;
    StorageAccountName = $StorageAccountName;
    ContainerName = "mof"
    MOFfile = "localhost.mof"
    VmName = "ub-ansible-client-9"
 };

 .\extension-ub.ps1 @DSC
