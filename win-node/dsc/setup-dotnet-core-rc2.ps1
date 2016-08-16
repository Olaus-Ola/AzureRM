Configuration Payload
{

Param ( [string] $nodeName )

Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DscResource -ModuleName @{ModuleName="xPSDesiredStateConfiguration"; ModuleVersion="3.0.3.4"}
Import-DscResource -ModuleName @{ModuleName="xWebAdministration"; ModuleVersion="1.13.0.0"}

Node $nodeName
  {

    LocalConfigurationManager 
        { 
            # This is false by default
            RebootNodeIfNeeded = $true
        } 

    WindowsFeature WebServerRole
    {
      Name = "Web-Server"
      Ensure = "Present"
    }
    WindowsFeature WebManagementConsole
    {
      Name = "Web-Mgmt-Console"
      Ensure = "Present"
    }

    xRemoteFile Payload {
        Uri             = "https://github.com/stuartshay/AzureRM/raw/master/WebSite.zip" 
        DestinationPath = "C:\WindowsAzure\website.zip" 
    }

    xRemoteFile DotNetCore {
        Uri             = "https://go.microsoft.com/fwlink/?LinkId=817246" 
        DestinationPath = "C:\WindowsAzure\DotNetCore.exe" 
    }

    xRemoteFile DotNetSDK {
        Uri             = "https://go.microsoft.com/fwlink/?LinkID=809122" 
        DestinationPath = "C:\WindowsAzure\DotNetSDK.exe"
    }

    Script PrepareEnvironment
    {
        TestScript = {
            Test-Path "C:\website\build\"
        }
        SetScript ={
            Expand-Archive C:\WindowsAzure\website.zip -DestinationPath c:\ -Force
			Write-Verbose "Info:Extracted payload"
			"Info:Extracted payload" | Out-File c:\website\build.log -Append -Force
        }
        GetScript = {@{Result = Test-Path "C:\website\build\"}}
        DependsOn = "[xRemoteFile]Payload"
    }

    Package DotNetCore
    {
           Ensure = "Present"
           Path = "C:\WindowsAzure\DotNetCore.exe"
           Arguments = "/q /norestart"
           Name = "DotNetCore"
           ProductId = "4ADC4F4A-2D55-442A-8655-FBF619F94A69"
           DependsOn = "[xRemoteFile]DotNetCore"
    }

    Package DotNetSDK
    {
           Ensure = "Present"
           Path = "C:\WindowsAzure\DotNetSDK.exe"
           Arguments = "/q /norestart"
           Name = "DotNetSDK"
           ProductId = "E7195A54-693B-4ECF-A7F5-1972A720068B"
           DependsOn = "[xRemoteFile]DotNetSDK"
    }

	xWebAppPool WebAppAppPool   
      {  
            Ensure          = "Present"  
            Name            = "web-app" 
            State           = "Started"
            managedRuntimeVersion = ""
      } 

    Script BuildApp
    {
        TestScript = { 
			if (Test-Path c:\website\build.log) {
				$content = Get-Content c:\website\build.log
				if ($content -match "Error:*" -or !($content -match "Success:*")) {return $false}
				else {return $true}
			}
            return $false
        }
        SetScript = {
			try {
				Write-Verbose "Info:Creating Task"
				"Info:Creating Task" | Out-File c:\website\build.log -Append

				$scriptpath = "C:\website\Build\Sixeyed.Iaas\src\Sixeyed.Iaas.WebApp\run.ps1"
				"Set-Location c:\website\build\sixeyed.iaas\src\sixeyed.iaas.webapp\" > $scriptpath
				"dotnet restore >> c:\website\restore.txt" >> $scriptpath
				"dotnet build >> c:\website\build.txt" >> $scriptpath
				"dotnet run >> c:\website\run.txt" >> $scriptpath
				
				$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File $scriptpath"
				$trigger = New-ScheduledTaskTrigger -AtStartup
				$runas = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
				$task = New-ScheduledTask -Action $action -Principal $runas -Trigger $trigger
				Register-ScheduledTask "dotnettask" -InputObject $task -Force
                Start-ScheduledTask dotnettask

				Write-Verbose "Info:Task Registered"
				"Success:Task Registered" | Out-File c:\website\build.log -Append
			}
			catch {
				Write-Verbose "Error:$($Error[0].Exception)"
				Out-File -FilePath c:\website\error.log -InputObject $error
				"Error:$($Error[0].Exception)" | Out-File c:\website\build.log -Append -Force
			}
		}
        GetScript = {@{Result = (Get-Content c:\website\build.log) -notmatch "Error*" }}
        DependsOn = @('[Package]DotNetCore', '[Package]DotNetSDK', '[Script]PrepareEnvironment')
    }
  }
}
