# Install chocolatey.
if (!(Get-Command choco -ErrorAction Ignore))
{
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression "$([Net.WebClient]::new().DownloadString('https://chocolatey.org/install.ps1'))"
}

& "$PSScriptRoot\powershell\setup.ps1"
& "$PSScriptRoot\vscode\setup.ps1"
& "$PSScriptRoot\git\setup.ps1"

choco install cmake
choco install 7zip