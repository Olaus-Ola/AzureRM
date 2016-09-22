#Login-AzureRMAccount

$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
$VnetName = "AzureRmVNet"
$SubNetIndex = 2

$StorageAccountName = "azurestoragez1"

#Extract-Base Image
$BI = @{

   ResourceGroupName = $ResourceGroupName;
   StorageAccountName = $StorageAccountName;
   ContainerName = "vm-images"
   VmName = "ub-ansible-0"
   NicName ="ub-ansible-nic-0"
   VhdNamePrefix = "ub-ansible-2016-09-13"

};
. ..\util\extract-base.ps1 @BI
