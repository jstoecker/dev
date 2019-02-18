function prompt
{
    Write-Host "$(pwd)" -ForegroundColor Yellow
    return '> '
}

function Set-DevEnv
{
    pushd 'C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC'
    cmd /c "vcvarsall.bat&set" |
    foreach {
      if ($_ -match "=") {
        $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
      }
    }
    popd
}

# Gets credentials for the current user, then caches them in a variable.
function Get-CurrentUserCredential
{
    if (!$script:CachedCredential)
    {
        $Username = "$env:USERDOMAIN\$env:USERNAME"
        $Password = Read-Host -AsSecureString -Prompt "Enter password for $Username"
        $script:CachedCredential = [PSCredential]::new($Username, $Password)
    }

    return $script:CachedCredential
}

# Returns servers configured to receive credentials delegated from the current machine.
function Get-DelegateCredentialServers
{
    $Property = Get-ItemProperty 'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentials'
    for ($i = 1; $Property.$i; $i++)
    {
        $Property.$i
    }
}

# Adds a server to the list of servers allowed to receive credentials delegated from the current machine.
function Add-DelegateCredentialServer($ServerName)
{
    # Avoid adding the same server name multiple times.
    if ((Get-DelegateCredentialServers) -contains "wsman/$ServerName")
    {
        return
    }

    Enable-WSManCredSSP -Role Client -DelegateComputer $ServerName
}

# Enters a PS remoting session on the named server using Credssp authentication. If the server is
# not already configured as a delegate on the current host, then it will be added to the list.
function Enter-PSSessionWithCredssp($ServerName, [switch]$ClearCachedCredentials)
{
    Add-DelegateCredentialServer $ServerName
    Enter-PSSession -Authentication Credssp -Credential (Get-CurrentUserCredential) -ComputerName $ServerName
}

Set-Alias -Name pss -Value Enter-PSSessionWithCredssp

Import-Module PSColor