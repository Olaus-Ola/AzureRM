Configuration Main
{

Param ( [string] $nodeName )

Import-DscResource -ModuleName PSDesiredStateConfiguration

Node $nodeName
  {
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

	Script Payload
    {
        TestScript = {
         Test-Path "C:\WindowsAzure\website.zip"
        }
        SetScript ={
          $source = "https://github.com/stuartshay/AzureRM/raw/master/WebSite.zip"
          $dest = "C:\WindowsAzure\website.zip"
          Invoke-WebRequest $source -OutFile $dest
  			  New-Item c:\website -ItemType Directory -Force
          Expand-Archive $dest -DestinationPath c:\
  	  		"Info:Extracted payload" | Out-File c:\website\build.log -Append -Force
        }
        GetScript = {@{Result = Test-Path "C:\WindowsAzure\website.zip"}}
    }
    Script DotNetCore
    {
        TestScript = {
          Test-Path "C:\WindowsAzure\DotNetCore.exe"
        }
        SetScript ={
          $source = "https://go.microsoft.com/fwlink/?LinkId=817246"
          $dest = "C:\WindowsAzure\DotNetCore.exe"
          Invoke-WebRequest $source -OutFile $dest
    			Start-Process $dest -ArgumentList "/q /norestart"
  		  	"Info:Installed DotNetCore" | Out-File c:\website\build.log -Append -Force
        }
        GetScript = {@{Result = Test-Path "C:\WindowsAzure\DotNetCore.exe"}}
        DependsOn = "[Script]Payload"
    }
	Script DotNetSDK
    {
        TestScript = {
          Test-Path "C:\WindowsAzure\DotNetSDK.exe"
        }
        SetScript ={
          $source = "https://go.microsoft.com/fwlink/?LinkID=809122"
          $dest = "C:\WindowsAzure\DotNetSDK.exe"
          Invoke-WebRequest $source -OutFile $dest
    			Start-Process $dest -ArgumentList "/q /norestart"
  		  	"Info:Installed DotNetSDK" | Out-File c:\website\build.log -Append -Force
        }
        GetScript = {@{Result = Test-Path "C:\WindowsAzure\DotNetSDK.exe"}}
        DependsOn = "[Script]Payload"
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

    				"Success:Task Registered" | Out-File c:\website\build.log -Append
		    	}
		      catch {
    				Out-File -FilePath c:\website\error.log -InputObject $error
    				"Error:$($Error[0].Exception)" | Out-File c:\website\build.log -Append -Force
			    }
	  	  }
        GetScript = {@{Result = (Get-Content c:\website\build.log) -notmatch "Error*" }}
        DependsOn = @('[Script]DotNetCore', '[Script]DotNetSDK', '[Script]Payload')
    }
  }
}
