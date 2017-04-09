class ConsoleColors
{
    $ColorTable = [ordered]@{
        'Black'       = (  0,   0,   0);
        'DarkBlue'    = (  0,   0, 128);
        'DarkGreen'   = (  0, 128,   0);
        'DarkCyan'    = (  0, 128, 128);
        'DarkRed'     = (128,   0,   0);
        'DarkMagenta' = (128,   0, 128);
        'DarkYellow'  = (128, 128,   0);
        'Gray'        = (192, 192, 192);
        'DarkGray'    = (128, 128, 128);
        'Blue'        = (  0,   0, 255);
        'Green'       = (  0, 255,   0);
        'Cyan'        = (  0, 255, 255);
        'Red'         = (255,   0,   0);
        'Magenta'     = (255,   0, 255);
        'Yellow'      = (255, 255,   0);
        'White'       = (255, 255, 255);
        }

    [int]$ScreenColorsBackground = 0
    [int]$ScreenColorsForeground = 15
    # Popup / WindowAlpha

    [void] SetColorValues([string]$ColorName, [int]$Red, [int]$Green, [int]$Blue)
    {
        $This.ColorTable[$ColorName] = $Red, $Green, $Blue            
    }

    [void] SetBackgroundColor([string]$ColorName)
    {
        $This.ScreenColorsBackground = [array]::IndexOf($This.ColorTable.Keys, $ColorName)
    }

    [void] SetForegroundColor([string]$ColorName)
    {
        $This.ScreenColorsForeground = [array]::IndexOf($This.ColorTable.Keys, $ColorName)
    }

    [void] Apply()
    {
        Push-Location -Path 'HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe'

        # Pack ScreenColors (F)oreground and (B)ackground into 0x000000BF
        $ScreenColors = ($This.ScreenColorsBackground -shl 4) -bor $This.ScreenColorsForeground
        Set-ItemProperty -Path . -Name ScreenColors -Type DWord -Value $ScreenColors

        for ($i = 0; $i -lt $This.ColorTable.Count; $i++)
        {
            $Name = "ColorTable$('{0:D2}' -f $i)"

            # Pack 8-bit RGB channels into 0x00BBGGRR
            $Value = ($This.ColorTable[$i][2] -shl 16) -bor
                     ($This.ColorTable[$i][1] -shl 8) -bor
                     ($This.ColorTable[$i][0])

            Set-ItemProperty -Path . -Name $Name -Type DWord -Value $Value
        }

        Pop-Location    
    }
}

# Creates a Windows shell shortcut (.lnk) file
function New-ShortcutLnk(
    [string]$Path,
    [string]$TargetPath, 
    [string]$Arguments,
    [string]$WorkingDirectory,
    [string]$Description
    )
{
    $Shell = New-Object -ComObject 'WScript.Shell'
    $Shortcut = $Shell.CreateShortcut($Path)
    $Shortcut.TargetPath = $TargetPath
    $Shortcut.Arguments = $Arguments
    $Shortcut.WorkingDirectory = $WorkingDirectory
    $Shortcut.Description = $Description
    $Shortcut.Save()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Shortcut) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Shell) | Out-Null
}

# Replaces the default Windows PowerShell shortcut with a new shortcut that
# does not override any of the registry-based console properties.
function Set-PowerShellStartShortcut
{
    $Path = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk"

    if (Test-Path $Path)
    {
        Remove-Item -Path $Path        
    }

    New-ShortcutLnk `
        -Path $Path `
        -TargetPath "$env:SystemRoot\system32\WindowsPowerShell\v1.0\powershell.exe" `
        -Arguments '-NoLogo' `
        -WorkingDirectory '%HOMEDRIVE%%HOMEPATH%' `
        -Description 'Performs object-based (command-line) functions'  
}


$ConsoleColors = [ConsoleColors]::new()
$ConsoleColors.SetForegroundColor('White')
$ConsoleColors.SetBackgroundColor('Black')
$ConsoleColors.SetColorValues('Red', 230, 64, 64)
$ConsoleColors.SetColorValues('Green', 173, 230, 34)
$ConsoleColors.SetColorValues('Blue', 64, 64, 200)
$ConsoleColors.SetColorValues('Cyan', 64, 200, 230)
$ConsoleColors.SetColorValues('Magenta', 64, 200, 200)
$ConsoleColors.SetColorValues('Yellow', 230, 200, 32)
$ConsoleColors.SetColorValues('DarkRed', 140, 32, 32)
$ConsoleColors.SetColorValues('DarkGreen', 32, 140, 32)
$ConsoleColors.SetColorValues('DarkBlue', 32, 32, 140)
$ConsoleColors.SetColorValues('DarkCyan', 32, 140, 150)
$ConsoleColors.SetColorValues('DarkMagenta', 32, 140, 140)
$ConsoleColors.SetColorValues('DarkYellow', 140, 140, 32)
$ConsoleColors.Apply()

Set-PowerShellStartShortcut

# Applications to install
# 1) vim & vim config
# 2) sublime text
# 3) powershell modules
# 4) man pages for git?