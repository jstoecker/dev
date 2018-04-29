

# Install VSCode.
choco install visualstudiocode --confirm --params "/NoDesktopIcon"
$env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' +
    [System.Environment]::GetEnvironmentVariable('PATH', 'User')

# Install extensions.
'ms-vscode.cpptools',
'ms-vscode.PowerShell',
'ms-vscode.sublime-keybindings',
'zhuangtongfa.Material-theme',
'twxs.cmake',
'eamodio.gitlens',
'yzhang.markdown-all-in-one' |
ForEach-Object { code --install-extension $_ }

# Copy settings.json.
& "$PSScriptRoot\update_settings.ps1"