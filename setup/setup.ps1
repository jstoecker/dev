# Run setup.ps1 in all subdirectories.
& "$PSScriptRoot\powershell\setup.ps1"
& "$PSScriptRoot\vscode\setup.ps1"
& "$PSScriptRoot\git\setup.ps1"

# TODO: CMake, VS, NuGet, VIM?