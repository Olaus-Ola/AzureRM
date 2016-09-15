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
   VmName = "ub-ansible-0"
   NicName ="ub-ansible-nic-0"
   VhdNamePrefix = "ub-ansible-2016-09-13"

};
 .\extract-ub.ps1 @BI