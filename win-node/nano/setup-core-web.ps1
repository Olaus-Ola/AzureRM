<#
Enter-PSSession $ip -Credential $cred

# Remote event log
Enable-NetFirewallRule -DisplayName "Windows Management Instrumentation (DCOM-In)"
Enable-NetFirewallRule -DisplayName "Remote Event Log Management (RPC)"
Enable-NetFirewallRule -DisplayName "Remote Event Log Management (RPC-EPMAP)"
Enable-NetFirewallRule -DisplayName "Remote Event Log Management (NP-In)"

# Remote server manager
Enable-NetFirewallRule -DisplayName "Remote Service Management (NP-In)"
Enable-NetFirewallRule -DisplayName "Remote Service Management (RPC)"
Enable-NetFirewallRule -DisplayName "Remote Service Management (RPC-EPMAP)"
Enable-NetFirewallRule -DisplayName "Remote Event Log Management (NP-In)"
Enable-NetFirewallRule -DisplayName "Remote Event Log Management (RPC)"
Enable-NetFirewallRule -DisplayName "Remote Event Log Management (RPC-EPMAP)"
Enable-NetFirewallRule -DisplayName "Windows Firewall Remote Management (RPC)"
Enable-NetFirewallRule -DisplayName "Windows Firewall Remote Management (RPC-EPMAP)"

#>

#region Basic Stuff
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
New-NetFirewallRule -Name "AspNet5 IIS" -DisplayName "Allow HTTP on TCP/8000" -Protocol TCP -LocalPort 8000 -Action Allow -Enabled True

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force 
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted 
Install-PackageProvider NanoServerPackage
Import-PackageProvider NanoServerPackage
Install-NanoServerPackage -Name Microsoft-NanoServer-Storage-Package
Install-NanoServerPackage -Name Microsoft-NanoServer-IIS-Package

$oldPath=(Get-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\’ -Name PATH).Path
$newPath=$oldPath+’;C:\dotnet\’
Set-ItemProperty -Path ‘HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\’ -Name PATH –Value $newPath
shutdown -r -t 5
Exit-PSSession
#endregion

#region Move Stuff Around
function DownloadFile {
    Param 
    (
    # What to download 
    [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
    [string]$SourcePath,

    # Where to download it
    [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=1)]
    [string]$DestinationPath
    )

    $TempPath = [System.IO.Path]::GetTempFileName()
    $handler = New-Object System.Net.Http.HttpClientHandler
    $client = New-Object System.Net.Http.HttpClient($handler)
    $client.Timeout = New-Object System.TimeSpan(0, 30, 0)
    $cancelTokenSource = [System.Threading.CancellationTokenSource]::new()
    $responseMsg = $client.GetAsync([System.Uri]::new($SourcePath), $cancelTokenSource.Token)
    $responseMsg.Wait()

    if (!$responseMsg.IsCanceled) {
        $response = $responseMsg.Result
        if ($response.IsSuccessStatusCode) {
            $downloadedFileStream = [System.IO.FileStream]::new($TempPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
            $copyStreamOp = $response.Content.CopyToAsync($downloadedFileStream)
            $copyStreamOp.Wait()
            $downloadedFileStream.Close()
            if ($copyStreamOp.Exception -ne $null) {
                throw $copyStreamOp.Exception
            }
        }
    }
    if ($DestinationPath -like "*.*") {
        Move-Item $TempPath -Destination $DestinationPath
    }
    else {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($TempPath, $DestinationPath)
        Remove-Item $TempPath
    }
}

$SourcePathDll = 'https://github.com/stuartshay/AzureRM/raw/master/win-node/nano/aspnetcore.dll'
$DestinationPathDll = 'C:\windows\system32\inetsrv\aspnetcore.dll'
$SourcePathXML = 'https://raw.githubusercontent.com/stuartshay/AzureRM/master/win-node/nano/aspnetcore_schema.xml'
$DestinationPathXML = 'C:\windows\system32\inetsrv\config\schema\aspnetcore_schema.xml'
$SourcePathPayload = 'https://github.com/stuartshay/AzureRM/raw/master/assets/webapp.zip'
$DestinationPathPayload = 'C:\inetpub'
$SourcePathDotNet = "https://go.microsoft.com/fwlink/?LinkID=809115"
$DestinationPathDotNet = 'C:\dotnet'

# I can confirm that downloading these files do not work, they have to be copied over smb
#DownloadFile -SourcePath $SourcePathDll -DestinationPath $DestinationPathDll
#DownloadFile -SourcePath $SourcePathXML -DestinationPath $DestinationPathXML
# These work
DownloadFile -SourcePath $SourcePathPayload -DestinationPath $DestinationPathPayload
DownloadFile -SourcePath $SourcePathDotNet -DestinationPath $DestinationPathDotNet

Copy-Item -Path c:\Windows\System32\forwarders\*.dll -Destination c:\dotnet
#endregion

#region IIS Stuff
# Backup existing applicationHost.config
copy C:\Windows\System32\inetsrv\config\applicationHost.config C:\Windows\System32\inetsrv\config\applicationHost_BeforeInstallingANCM.config

Import-Module IISAdministration
$sm = Get-IISServerManager
$sm.GetApplicationHostConfiguration().RootSectionGroup.Sections.Add("appSettings")
$appHostconfig = $sm.GetApplicationHostConfiguration()
$section = $appHostconfig.GetSection("system.webServer/handlers")
$section.OverrideMode="Allow"
$sectionaspNetCore = $appHostConfig.RootSectionGroup.SectionGroups["system.webServer"].Sections.Add("aspNetCore")
$sectionaspNetCore.OverrideModeDefault = "Allow"
$globalModules = Get-IISConfigSection "system.webServer/globalModules" | Get-IISConfigCollection
New-IISConfigCollectionElement $globalModules -ConfigAttribute @{"name"="AspNetCoreModule";"image"=$DestinationPathDll}
$modules = Get-IISConfigSection "system.webServer/modules" | Get-IISConfigCollection
New-IISConfigCollectionElement $modules -ConfigAttribute @{"name"="AspNetCoreModule"}
$sm.CommitChanges()

# Backup existing applicationHost.config
copy C:\Windows\System32\inetsrv\config\applicationHost.config C:\Windows\System32\inetsrv\config\applicationHost_AfterInstallingANCM.config

$sm = Get-IISServerManager
$sm.ApplicationPools.Add("aspnetcore")
$sm.CommitChanges()

$ap = Get-IISAppPool -Name "aspnetcore"
$ap.Start()

Start-IISCommitDelay
$mysite = New-IISSite -Name "aspnetcore" -BindingInformation "*:8000:" -PhysicalPath "C:\inetpub\webapp\wwwroot" -Passthru
$mysite.Applications["/"].ApplicationPoolName = "aspnetcore"
Stop-IISCommitDelay
#endregion
