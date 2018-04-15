

# code --list-extensions
# https://go.microsoft.com/fwlink/?Linkid=852157
# Invoke-WebReqest -Url https://go.microsoft.com/fwlink/?Linkid=852157 -OutFile vscode-setup.exe

$Extensions = 'zhuangtongfa.Material-theme',
              'twxs.cmake',
              'ms-vscode.cpptools',
              'ms-vscode.PowerShell',
              'ms-vscode.sublime-keybindings'

$Extensions | ForEach-Object { code --install-extension $_ }


# Download VSCode
# Install VSCode
# Add to PATH
# Install extnesions
# Copy settings.json