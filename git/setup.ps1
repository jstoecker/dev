# Install Git.
choco install git --confirm --params "/NoShellIntegration"
$env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' +
    [System.Environment]::GetEnvironmentVariable('PATH', 'User')

# Copy global .gitconfig, and allow user to edit it.
& "$PSScriptRoot\update_config.ps1"
git config --global --edit