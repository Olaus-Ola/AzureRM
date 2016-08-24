Login-AzureRMAccount
Set-Location D:\Documents\GitHub\AzureRM\win-node\

$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
$VaultName = 'AzureRMVault'

$VnetName = "AzureRmVNet"
$SubNetIndex = 2

$StorageAccountName = "azurestoragez1"

$i = 1
For ($i=1; $i -lt 2; $i++) {
  $VirtualMachine = @{
       ResourceGroupName = $ResourceGroupName;
       Location = $Location;
       VaultName = $VaultName;
       StorageAccountName = $StorageAccountName;
       VnetName = $VnetName;
       SubnetIndex = $SubnetIndex;
       VmName = "nano-server-$i";
       NicName = "nano-server-nic-$i";
       VmSize = "Standard_D1_v2";
       };

    . .\..\base\build-win-nano.ps1 @VirtualMachine;

}

