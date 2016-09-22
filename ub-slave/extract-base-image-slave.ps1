#Login-AzureRMAccount
Set-Location C:\Users\Pari\Desktop\harpreet\Auto-deploy-docker-azure\ub-node


$ResourceGroupName = "ansible-resource"
$Location = "Canada Central"
$VnetName = "Ansible-network"
$SubNetIndex = 0

$StorageAccountName = "ansiblestorage635"

#Extract-Base Image
$BI = @{

   ResourceGroupName = $ResourceGroupName;
   StorageAccountName = $StorageAccountName;
   ContainerName = "vm-images"
   VmName = "u-ansible-0"
   NicName ="u-ansible-nic-0"
   VhdNamePrefix = "u-ansible-2016-09-13"

};
 .\extract-ub.ps1 @BI
