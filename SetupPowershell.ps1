class ConsoleColors
{
    # Table of 16 colors with associated names. Each entry is initialized with
    # Windows' default color values for a command prompt (not PowerShell).
    $ColorTable = [ordered]@{
        'Black'       = (  0,   0,   0); # index = 0
        'DarkBlue'    = (  0,   0, 128); # index = 1
        'DarkGreen'   = (  0, 128,   0); # index = 2
        'DarkCyan'    = (  0, 128, 128); # index = 3
        'DarkRed'     = (128,   0,   0); # index = 4
        'DarkMagenta' = (128,   0, 128); # index = 5
        'DarkYellow'  = (128, 128,   0); # index = 6
        'Gray'        = (192, 192, 192); # index = 7
        'DarkGray'    = (128, 128, 128); # index = 8
        'Blue'        = (  0,   0, 255); # index = 9
        'Green'       = (  0, 255,   0); # index = 10
        'Cyan'        = (  0, 255, 255); # index = 11
        'Red'         = (255,   0,   0); # index = 12
        'Magenta'     = (255,   0, 255); # index = 13
        'Yellow'      = (255, 255,   0); # index = 14
        'White'       = (255, 255, 255); # index = 15
        }

    [UInt16]$FillBackground = 0x5 # Screen text background color table index [0, 15]
    [UInt16]$FillForeground = 0x6 # Screen text foreground color table index [0, 15]
    [UInt16]$PopupBackground = 0xF # Popup text background color table index [0, 15]
    [UInt16]$PopupForeground = 0x3 # Popup text foreground color table index [0, 15]

    [Int16]$ScreenBufferSizeX = 120
    [Int16]$ScreenBufferSizeY = 3000
    [Int16]$WindowSizeX = 120
    [Int16]$WindowSizeY = 50
    [Int16]$WindowOriginX = 0
    [Int16]$WindowOriginY = 0
    [UInt32]$FontSize = 786432 # 12pt
    [UInt32]$FontFamily = 32
    [UInt32]$FontWeight = 400
    [String]$FaceName = 'Lucida Console'
    [UInt32]$CursorSize = 25
    [UInt32]$FullScreen = 0
    [UInt32]$QuickEdit = 1
    [UInt32]$InsertMode = 1
    [UInt32]$AutoPosition = 0
    [UInt32]$HistoryBufferSize = 50
    [UInt32]$NumberOfHistoryBuffers = 4
    [UInt32]$HistoryNoDup = 0

    # Changes the RGB values for the named color in the color table. For example,
    # SetColorValues('Black', 255, 0, 0) will result in the first color table entry
    # (associated with the name 'Black') to be pure red. 
    [void] SetColorValues([string]$ColorName, [int]$Red, [int]$Green, [int]$Blue)
    {
        $This.ColorTable[$ColorName] = $Red, $Green, $Blue            
    }

    [void] SetBackgroundColor([string]$ColorName)
    {
        $This.FillBackground = [array]::IndexOf($This.ColorTable.Keys, $ColorName)
    }

    [void] SetForegroundColor([string]$ColorName)
    {
        $This.FillForeground = [array]::IndexOf($This.ColorTable.Keys, $ColorName)
    }

    # TODO additional setters

    [void] ResetRegistryValues()
    {
        # TODO : back to default windows
    }

    # Saves the console color properties to the Windows registry. The registry
    # properties will apply to instances of powershell.exe launched directly
    # (i.e. not through a shortcut); these are the 'default' properties for
    # the console.
    [void] SaveRegistryValues()
    {
        # TODO: apply to x86 as well?
        Push-Location -Path 'HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe'

        # TODO: apply all properties

        # Pack ScreenColors (F)oreground and (B)ackground into 0x000000BF
        $ScreenColors = ($This.FillBackground -shl 4) -bor $This.FillForeground
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

    # Creates a shorcut (.lnk) file with the color properties embedded into it.
    [void] CreateShortcut([String]$Path)
    {
        # Resolve path to a fully qualified path.
        $Path = $Script:ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)

        # If the path already exists, delete it.
        if (Test-Path $Path)
        {
            Remove-Item -Path $Path        
        }

        # Create the shortcut file.
        $Shell = New-Object -ComObject 'WScript.Shell'
        $Shortcut = $Shell.CreateShortcut($Path)
        $Shortcut.TargetPath = "$env:SystemRoot\system32\WindowsPowerShell\v1.0\powershell.exe"
        $Shortcut.Arguments = '-NoLogo'
        $Shortcut.WorkingDirectory = '%HOMEDRIVE%%HOMEPATH%'
        $Shortcut.Description = 'Performs object-based (command-line) functions'
        $Shortcut.Save()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Shortcut) | Out-Null
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Shell) | Out-Null

        # Add a console data block to the end of the file.
        $FileStream = $Null
        $Writer = $Null
        try
        {
            # Open the shortcut file for writing.
            $FileStream = [IO.FileStream]::new(
                $Path, 
                [IO.FileMode]::Open, 
                [IO.FileAccess]::ReadWrite
                )
            $Writer = [IO.BinaryWriter]::new($FileStream)

            # Start writing at the position of the terminal block (4 bytes).
            # This will overwrite the terminal block, so we'll add it back in
            # again when finished.
            $FileStream.Position = $FileStream.Length - 4

            $FaceNameBytes = [byte[]]::new(64)
            [Text.Encoding]::Unicode.GetBytes(
                $This.FaceName, 
                0, 
                $This.FaceName.Length, 
                $FaceNameBytes, 
                0
                )

            [byte[]]$ColorTableBytes = [byte[]]::new(64)
            $ByteIndex = 0
            for ($ColorTableIndex = 0; $ColorTableIndex -lt 16; $ColorTableIndex++)
            {
                $ColorTableBytes[$ByteIndex++] = $This.ColorTable[$ColorTableIndex][0]
                $ColorTableBytes[$ByteIndex++] = $This.ColorTable[$ColorTableIndex][1]
                $ColorTableBytes[$ByteIndex++] = $This.ColorTable[$ColorTableIndex][2]
                $ColorTableBytes[$ByteIndex++] = 0
            }

            [UInt16]$FillAttributes = ($This.FillBackground -shl 4) -bor $This.FillForeground
            [UInt16]$PopupFillAttributes = ($This.PopupBackground -shl 4) -bor $This.PopupForeground

            $Writer.Write([UInt32]'0x000000CC') # BlockSize
            $Writer.Write([UInt32]'0xA0000002') # BlockSignature
            $Writer.Write($FillAttributes)
            $Writer.Write($PopupFillAttributes)
            $Writer.Write($This.ScreenBufferSizeX)
            $Writer.Write($This.ScreenBufferSizeY)
            $Writer.Write($This.WindowSizeX)
            $Writer.Write($This.WindowSizeY)
            $Writer.Write($This.WindowOriginX)
            $Writer.Write($This.WindowOriginY)
            $Writer.Write([UInt32]0) # Unused 1
            $Writer.Write([UInt32]0) # Unused 2
            $Writer.Write($This.FontSize)
            $Writer.Write($This.FontFamily)
            $Writer.Write($This.FontWeight)
            $Writer.Write($FaceNameBytes)
            $Writer.Write($This.CursorSize)
            $Writer.Write($This.FullScreen)
            $Writer.Write($This.QuickEdit)
            $Writer.Write($This.InsertMode)
            $Writer.Write($This.AutoPosition)
            $Writer.Write($This.HistoryBufferSize)
            $Writer.Write($This.NumberOfHistoryBuffers)
            $Writer.Write($This.HistoryNoDup)
            $Writer.Write($ColorTableBytes)

            # Add a new terminal block
            $Writer.Write([UInt32]0)
        }
        finally
        {
            if ($Writer) { $Writer.Close() }
            if ($FileStream) { $FileStream.Close() }
        }
    }
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
$ConsoleColors.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk")