Login-AzureRMAccount

$Location = 'East US 2'

#Windows 
Get-AzureRmVMImagePublisher -Location $Location | Select PublisherName | Out-GridView
Get-AzureRmVmImageOffer -Location $Location -PublisherName 'MicrosoftVisualStudio' | Out-GridView
Get-AzureRmVmImageSku -Location $Location -PublisherName 'MicrosoftVisualStudio' -Offer "Windows" | Out-GridView
Get-AzureRmVMImage -Location $Location -PublisherName "MicrosoftVisualStudio" -Offer "Windows" -Skus "10-Enterprise-N" | select version

$Publisher = (Get-AzureRmVMImagePublisher -Location $Location) | select -ExpandProperty PublisherName | where { $_ -like '*Microsoft*Windows*Server' }
$Offer = (Get-AzureRmVMImageOffer -Location $Location -PublisherName $Publisher) | select -ExpandProperty Offer | where { $_ -like '*Windows*' } 
$Sku = (Get-AzureRmVMImageSku -Location $Location -PublisherName $Publisher -Offer $Offer) | select -ExpandProperty Skus | where { $_ -like '*2012-R2-Datacenter*' } 
$Versions = (Get-AzureRmVMImage -Location $Location -Offer $Offer -PublisherName $Publisher -Skus $Sku) | select -ExpandProperty Version

write-output("Publisher: " + $Publisher) ##MicrosoftWindowsServer
write-output("Offer:" + $Offer) ##WindowsServer
write-output("Sku:" + $Sku ) ##2012-R2-Datacenter
write-output("Current Versions:" + $Versions) #4.0.20160617

#Windows Nano Server 
$Publisher = "MicrosoftWindowsServer"
$Offer = "WindowsServer"
$Sku = "2016-Nano-Server-Technical-Preview"
$Versions = (Get-AzureRmVMImage -Location $Location -Offer $Offer -PublisherName $Publisher -Skus $Sku) | select -ExpandProperty Version


#Canonical UbuntuServer
Get-AzureRmVMImagePublisher -Location $Location | Select PublisherName | Out-GridView
Get-AzureRmVmImageOffer -Location $Location -PublisherName 'Canonical' | Out-GridView
Get-AzureRmVmImageSku -Location $Location -PublisherName 'Canonical' -Offer "UbuntuServer" | Out-GridView
Get-AzureRmVMImage -Location $Location -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "16.04.0-LTS" | Out-GridView


## Get Image Sizes 
Get-AzureRmVMSize –Location $Location |ft


#Modules 
# System modules: %windir%\System32\WindowsPowerShell\v1.0\Modules
# Current user modules:  %UserProfile%\Documents\WindowsPowerShell\Modules

Get-Module -ListAvailable -FullyQualifiedName xPSDesiredStateConfiguration	
Remove-Module -Name xPSDesiredStateConfiguration

Get-Command -Module xPSDesiredStateConfiguration | Select-Object -Property name, version -First 3
Remove-Module -Name xPSDesiredStateConfiguration

Find-Module -name xPSDesiredStateConfiguration -requiredversion 3.0.3.4 | install-module -force
  
