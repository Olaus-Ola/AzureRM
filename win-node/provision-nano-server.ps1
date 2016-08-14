Login-AzureRMAccount
Set-Location D:\Documents\GitHub\AzureRM\win-node\

$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
$VaultName = 'AzureRMVault'

$VnetName = "AzureRmVNet"
$SubNetIndex = 2

$StorageAccountName = "azurestoragez1"


#https://blogs.technet.microsoft.com/nanoserver/2016/05/27/nano-server-tp5-iaas-image-in-azure-updated
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -scope CurrentUser
Import-Module .\modules\NanoServerAzureHelper.psm1 -Verbose 


New-NanoServerAzureVM -Location $Location –VMName "nanoserver" -AdminUsername "Navigator" `
                      -VaultName $VaultName -ResourceGroupName $ResourceGroupName -Verbose 


Get-AzureRmPublicIpAddress -ResourceGroupName "AzureRM"


# PowerShell Remote Session
Enter-PSSession -ConnectionUri "https://nanoserver.eastus2.cloudapp.azure.com:5986/WSMAN" -Credential Navigator


#############################


# Get PowerShell Version
$PSVersionTable; 
Get-PSRepository
Get-PackageProvider -ListAvailable


##Nuget Provider Broken
#https://github.com/OneGet/NanoServerPackage/issues/4

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force 
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted 
 

#Install all available updates 
$sess = New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession  
$scanResults = Invoke-CimMethod -InputObject $sess -MethodName ApplyApplicableUpdates  
Restart-Computer

## THIS IS BROKEN --- 
Install-PackageProvider NanoServerPackage
Import-PackageProvider NanoServerPackage
Install-NanoServerPackage -Name Microsoft-NanoServer-Storage-Package
Install-NanoServerPackage -Name Microsoft-NanoServer-IIS-Package


#############################

#Testing

# Deploy the Template to the Resource Group
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile 'templates\WindowsNanoServerVM.json' `
                                   -TemplateParameterFile 'templates\WindowsNanoServerVM.parameters.json' `
                                   -Verbose


https://alexandrebrisebois.wordpress.com/2016/02/18/deploying-nano-server-to-microsoft-azure/
https://blogs.technet.microsoft.com/nanoserver/2016/05/27/nano-server-tp5-iaas-image-in-azure-updated


$i = 1
For ($i=1; $i -lt 2; $i++) {
  $VitualMachine = @{
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

    . .\..\base\build-win-nano.ps1 @VitualMachine;

}
