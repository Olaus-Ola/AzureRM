$AutomationAccount = Get-AzureRMAutomationAccount -Name AzureAutomation -ResourceGroupName AzureAutomation
$AutomationAccount | Register-AzureRmAutomationDscNode -AzureVMName testovm -AzureVMResourceGroup azurerm -AzureVMLocation 'East US 2'

$params = @{'AzureResourceGroup'='AzureRM'; 'Shutdown'='false'}
Start-AzureRMAutomationRunbook -AutomationAccountName 'AzureAutomation' -Name 'Shutdown-Start-VMs-By-Resource-Group' -Parameters $params