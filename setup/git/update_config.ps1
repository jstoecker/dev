<#
.SYNOPSIS
Script for copying default .gitconfig to user .gitconfig, or copying
user .gitconfig to this directory to update/merge with the defaults.
#>
param
(
    [switch]$Merge
)

$UserConfigPath = "$env:USERPROFILE\.gitconfig"
$DefaultConfigPath = "$PSScriptRoot\.gitconfig"

if ($Merge)
{
    Copy-Item -Path $UserConfigPath -Destination $DefaultConfigPath
}
else
{
    Copy-Item -Path $DefaultConfigPath -Destination $UserConfigPath
}