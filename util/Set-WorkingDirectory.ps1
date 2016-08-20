#Persisting Azure PowerShell logins
#https://blogs.msdn.microsoft.com/stuartleeks/2015/12/11/persisting-azure-powershell-logins/

Save-AzureRmProfile –Path C:\your-path-here\AzureRmProfile.json

#Then update your profile (I like to run “ise $profile”) to include

Select-AzureRmProfile –Path C:\your-path-here\AzureRmProfile.json | out-null


#https://gist.github.com/mattmcnabb/4f682ffbbcca358c2ae8

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

