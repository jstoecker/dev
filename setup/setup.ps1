# Run setup.ps1 in all subdirectories.
# & "$PSScriptRoot\powershell\setup.ps1"
# & "$PSScriptRoot\vscode\setup.ps1"
# & "$PSScriptRoot\git\setup.ps1"

# TODO: CMake, VS, NuGet, VIM?

# Install choco

# 7zip?

# choco install 

if (!(Get-Command choco -ErrorAction Ignore))
{
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression "$([Net.WebClient]::new().DownloadString('https://chocolatey.org/install.ps1'))"
}

choco install visualstudiocode --confirm --params "/NoDesktopIcon"


