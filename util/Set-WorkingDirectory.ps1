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

