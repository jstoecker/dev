# Install Git.
choco install git --confirm --params "/NoShellIntegration"
$env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' + 
    [System.Environment]::GetEnvironmentVariable('PATH', 'User')

# Copy global .gitconfig, and allow user to edit it.
Copy-Item "$PSScriptRoot\.gitconfig" "$env:USERPROFILE\.gitconfig"
git config --global --edit