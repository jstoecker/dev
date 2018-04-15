# Download VSCode installer.
$SetupPath = "$env:USERPROFILE\Downloads\VSCodeSetup-x64.exe"
if (!(Test-Path $SetupPath))
{
    Write-Host "- Downloading VSCode to $SetupPath"
    [Net.WebClient]::new().DownloadFile('https://go.microsoft.com/fwlink/?Linkid=852157', $SetupPath)
}

# Run VSCode setup, and refresh the PATH once it finishes.
Write-Host "- Running VSCode setup"
Start-Process $SetupPath -Wait
$env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' + 
    [System.Environment]::GetEnvironmentVariable('PATH', 'User')

# Install extensions.
$Extensions = 'zhuangtongfa.Material-theme',
    'twxs.cmake',
    'ms-vscode.cpptools',
    'ms-vscode.PowerShell',
    'ms-vscode.sublime-keybindings'

$Extensions | ForEach-Object { code --install-extension $_ }

# Global configuration.
# Copy-Item "$PSScriptRoot\.gitconfig" "$env:USERPROFILE\.gitconfig"
# git config --global --edit