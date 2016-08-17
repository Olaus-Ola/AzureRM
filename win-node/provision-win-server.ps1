Login-AzureRMAccount
Set-Location C:\Users\sshay\Documents\GitHub\AzureRM\win-node


$ResourceGroupName = 'AzureRM'
$Location = 'East US 2'
$VnetName = "AzureRmVNet"
$SubNetIndex = 2

$StorageAccountName = "azurestoragez1"


#region Publish DSC Image 
  
  # Azure Blob Storage 
  Publish-AzureRmVMDscConfiguration -ConfigurationPath .\dsc\setup-iis-web.ps1 `
                                    -ResourceGroupName $ResourceGroupName -StorageAccountName $storageAccountName -Force 

  #Local File System
  #FILE TO UPLOAD: setup-iis-web.ps1.zip
  #CONFIGURATIONFUNCTION: setup-iis-web.ps1\WebSite 
  #VERSION: 2.17
  Publish-AzureRmVMDscConfiguration -ConfigurationPath .\dsc\setup-iis-web.ps1 -OutputArchivePath ".\setup-iis-web.ps1.zip" -Force 


  
  #find-module -name xPSDesiredStateConfiguration -requiredversion 3.0.3.4 | install-module -force
  #setup-dotnet-core-rc2.ps1\Payload
  Publish-AzureRmVMDscConfiguration -ConfigurationPath .\dsc\setup-dotnet-core-rc2.ps1 -OutputArchivePath ".\setup-dotnet-core-rc2.ps1.zip" -Force 


  #Get Product Id for DSC Install
  Get-WmiObject Win32_Product | Format-Table IdentifyingNumber, Name, Version 

#endregion


# Build Base Image 
$i = 52
For ($i=52; $i -lt 55; $i++) {
  
  $VitualMachine = @{
       ResourceGroupName = $ResourceGroupName;
       Location = $Location;
       StorageAccountName = $StorageAccountName;
       VnetName = $VnetName;
       SubnetIndex = $SubnetIndex;
       VmName = "win-server-$i";
       NicName = "win-server-nic-$i";
       VmSize = "Standard_D2_v2";
       };

    . .\..\base\build-win-server.ps1 @VitualMachine;
}



# Check machine in Azure Portal
# Manually Reboot 
 
# Manually Add - PowerShell Desired State Configuration
# -- Upload Zip
#    CONFIGURATIONFUNCTION: setup-iis-web.ps1\WebSite 
#    VERSION: 2.17



#Apply DSC Configuration

$i = 3
For ($i=3; $i -lt 4; $i++) {

 $achiveblobName = 'setup-iis-web.zip';

 Set-AzureRmVMDSCExtension -ResourceGroupName $ResourceGroupName -VMName  win-server-$i -Version '2.8' `
                              -ArchiveBlobName $achiveblobName `
                              -ArchiveStorageAccountName $StorageAccountName `
                              -ConfigurationName "ConfigureWeb" -AutoUpdate

}


$null = Register-ObjectEvent -InputObject $psISE.PowerShellTabs.SelectedPowerShellTab -EventName 'PropertyChanged' -Action {
    if($args[1].PropertyName -eq 'LastEditorWithFocus' -and $env:AutoChangeLocation -eq $true)
    {
        $Location = Get-Location
        $NewLocation = split-path $psISE.PowerShellTabs.SelectedPowerShellTab.Files.SelectedFile.FullPath
        if ($Location.path -ne $NewLocation)
        {
            Set-Location $NewLocation
            Out-Host -InputObject ' '
            prompt
        }
    }
}
[Environment]::SetEnvironmentVariable('AutoChangeLocation',$true)



