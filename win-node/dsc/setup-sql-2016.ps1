#requires -Version 5

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
param ()

Configuration SQLSA
{
    Import-DscResource -Module xSQLServer
    Import-DscResource -Module xStorage
    Import-DscResource -ModuleName xPSDesiredStateConfiguration


    # Set role and instance variables
    $Roles = $AllNodes.Roles | Sort-Object -Unique
    foreach($Role in $Roles)
    {
        $Servers = @($AllNodes.Where{$_.Roles | Where-Object {$_ -eq $Role}}.NodeName)
        Set-Variable -Name ($Role.Replace(" ","").Replace(".","") + "s") -Value $Servers
        if($Servers.Count -eq 1)
        {
            Set-Variable -Name ($Role.Replace(" ","").Replace(".","")) -Value $Servers[0]
            if(
                $Role.Contains("Database") -or
                $Role.Contains("Datawarehouse") -or
                $Role.Contains("Reporting") -or
                $Role.Contains("Analysis") -or 
                $Role.Contains("Integration")
            )
            {
                $Instance = $AllNodes.Where{$_.NodeName -eq $Servers[0]}.SQLServers.Where{$_.Roles | Where-Object {$_ -eq $Role}}.InstanceName
                Set-Variable -Name ($Role.Replace(" ","").Replace(".","").Replace("Server","Instance")) -Value $Instance
            }
        }
    }    

    Node $AllNodes.NodeName
    {
        # Set LCM to reboot if needed
        LocalConfigurationManager
        {
            DebugMode = "ForceModuleImport"
            RebootNodeIfNeeded = $true
        }
        
        WindowsFeature "NET-Framework-Core"
        {
            Ensure = "Present"
            Name = "NET-Framework-Core"
        }
        
        File SetupDir
        {
            Type = 'Directory'
            DestinationPath = 'c:\Setup'
            Ensure = "Present"    
        }

        xRemoteFile SQLServer2016Package
        {  
             Uri             = "https://azurestoragez1.blob.core.windows.net/software/en_sql_server_2016_enterprise_x64_dvd_8701793.iso"
             DestinationPath = 'c:\Setup\en_sql_server_2016_enterprise_x64_dvd_8701793.iso'
             DependsOn       = "[File]SetupDir"
        }

        xMountImage MountSQLImage
        {
        
            Name = 'SQL Disk'
            ImagePath = 'c:\Setup\en_sql_server_2016_enterprise_x64_dvd_8701793.iso'
            DriveLetter = 's:'
            Ensure = 'Present'
            DependsOn = "[xRemoteFile]SQLServer2016Package"
        }
        

        File MoveSqlSourceFiles
        {
            SourcePath = "s:"
            DestinationPath = "C:\Source"
            Ensure = "present"
            Type = "Directory"
            Recurse = $true
            #DependsOn = "[xMountImage]MountSQLImage"
        }
        
        # Install SQL Instances
        foreach($SQLServer in $Node.SQLServers)
        {
            $SQLInstanceName = $SQLServer.InstanceName

            $Features = "SQLENGINE,FULLTEXT"

            if($Features -ne "")
            {
                xSqlServerSetup ($Node.NodeName + $SQLInstanceName)
                {
                    DependsOn = @("[WindowsFeature]NET-Framework-Core", "[File]MoveSqlSourceFiles")
                    
                    SourcePath = $Node.SourcePath
                    SetupCredential = $Node.InstallerServiceAccount
                    InstanceName = $SQLInstanceName
                    Features = $Features
                    SQLSysAdminAccounts = $Node.AdminAccount
                    InstallSharedDir = "C:\Program Files\Microsoft SQL Server"
                    InstallSharedWOWDir = "C:\Program Files (x86)\Microsoft SQL Server"
                    InstanceDir = "c:\Program Files\Microsoft SQL Server"
                    InstallSQLDataDir = "c:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                    SQLUserDBDir = "c:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                    SQLUserDBLogDir = "c:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                    SQLTempDBDir = "c:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                    SQLTempDBLogDir = "c:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                    SQLBackupDir = "c:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Data"
                    ASDataDir = "c:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Data"
                    ASLogDir = "c:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Log"
                    ASBackupDir = "c:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Backup"
                    ASTempDir = "c:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Temp"
                    ASConfigDir = "c:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Config"
                }

                xSqlServerFirewall ($Node.NodeName + $SQLInstanceName)
                {
                    DependsOn = ("[xSqlServerSetup]" + $Node.NodeName + $SQLInstanceName)
                    SourcePath = $Node.SourcePath
                    InstanceName = $SQLInstanceName
                    Features = $Features
                }
            }
        }

        # Install SQL Management Tools
        if($SQLServer2012ManagementTools | Where-Object {$_ -eq $Node.NodeName})
        {
            xSqlServerSetup "SQLMT"
            {
                DependsOn = "[WindowsFeature]NET-Framework-Core"
                SourcePath = $Node.SourcePath
                SetupCredential = $Node.InstallerServiceAccount
                InstanceName = "NULL"
                Features = "SSMS,ADV_SSMS"
            }
        }
    }
}

$InstallerServiceAccount = Get-Credential "testo"

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true

            SourcePath = "C:\"
            InstallerServiceAccount = $InstallerServiceAccount
            LocalSystemAccount = $InstallerServiceAccount

            AdminAccount = "testo"

        }
        @{
            NodeName = "localhost"
            SQLServers = @(
                @{
                    InstanceName = "MSSQLSERVER"
                }
            )
        }
    )
}

foreach($Node in $ConfigurationData.AllNodes)
{
    if($Node.NodeName -ne "*")
    {
        Start-Process -FilePath "robocopy.exe" -ArgumentList ("`"C:\Program Files\WindowsPowerShell\Modules`" `"\\" + $Node.NodeName + "\c$\Program Files\WindowsPowerShell\Modules`" /e /purge /xf") -NoNewWindow -Wait
    }
}

SQLSA -ConfigurationData $ConfigurationData
Set-DscLocalConfigurationManager -Path .\SQLSA -Verbose
#Start-DscConfiguration -Path .\SQLSA -Verbose -Wait -Force