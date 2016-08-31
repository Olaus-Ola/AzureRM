Configuration Payload
{

Param (
    [Parameter(Mandatory=$false)][string] $nodeName
    )

Import-DscResource -ModuleName PSDesiredStateConfiguration
Import-DscResource -ModuleName @{ModuleName="xPSDesiredStateConfiguration"; ModuleVersion="3.13.0.0"}
Import-DscResource -ModuleName xDatabase


Node $nodeName
{
    LocalConfigurationManager 
    { 
        # This is false by default
        RebootNodeIfNeeded = $true
    } 

}
