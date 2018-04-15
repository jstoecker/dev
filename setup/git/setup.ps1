# Get link to the latest version of Git.
$DownloadUrl = ((Invoke-WebRequest 'https://git-scm.com/download/win' -UseBasicParsing).Links -match '64-bit.exe').href

# Download Git.
$GitSetupPath = "$env:USERPROFILE\Downloads\$($DownloadUrl | Split-Path -Leaf)"
if (!(Test-Path $GitSetupPath))
{
    Write-Host "- Downloading Git to $GitSetupPath"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    [Net.WebClient]::new().DownloadFile($DownloadUrl, $GitSetupPath)
}

# Run Git setup, and refresh the PATH once it finishes.
Write-Host "- Running Git setup"
Start-Process $GitSetupPath -Wait
$env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' + 
    [System.Environment]::GetEnvironmentVariable('PATH', 'User')

# Global configuration.
Copy-Item "$PSScriptRoot\.gitconfig" "$env:USERPROFILE\.gitconfig"
git config --global --edit