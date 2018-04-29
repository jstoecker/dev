<#
.SYNOPSIS
Script for copying default settings.json to user settings.json, or copying
user settings.json to this directory to update/merge with the defaults.
#>
param
(
    [switch]$Merge
)

$UserSettingsPath = "$env:APPDATA\Code\User\settings.json"
$DefaultSettingsPath = "$PSScriptRoot\settings.json"

if ($Merge)
{
    Copy-Item -Path $UserSettingsPath -Destination $DefaultSettingsPath
}
else
{
    Copy-Item -Path $DefaultSettingsPath -Destination $UserSettingsPath
}