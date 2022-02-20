function Write-Host {
    param(
        $object,
        [ConsoleColor]$foregroundColor,
        [ConsoleColor]$backgroundColor,
        [switch]$nonewline
    )
        if (!(Get-Command Write-HostOriginal -ea 0).name){ # doit etre embarque (pour les scriptblock)
            $global:ConsoleOutput = ''
            $metaData = New-Object System.Management.Automation.CommandMetaData (Get-Command 'Microsoft.PowerShell.Utility\Write-Host')
            Invoke-Expression "function Global:Write-HostOriginal { $([System.Management.Automation.ProxyCommand]::create($metaData)) }"
        }

        # https://msdn.microsoft.com/en-us/library/system.consolecolor(v=vs.110).aspx
        # Converted to closest ANSI SGR equivalent
        $AnsiColor = [pscustomobject][ordered]@{ # doit etre embarque (pour les scriptblock)
            ForeGround = [pscustomobject][ordered]@{
                Black = 30
                Red = 91
                DarkRed = 31
                Green = 92
                DarkGreen = 32
                Yellow = 93
                DarkYellow = 33
                Blue = 94
                DarkBlue = 34
                Magenta = 95
                DarkMagenta = 35
                Cyan = 96
                DarkCyan = 36
                White = 97
                Gray = 37
                DarkGray = 90
            }
            BackGround = [pscustomobject][ordered]@{
                Black = 40
                White = 107
                Red = 101
                DarkRed = 41
                Green = 102
                DarkGreen = 42
                Yellow = 103
                DarkYellow = 43
                Blue = 104
                DarkBlue = 44
                Magenta = 105
                DarkMagenta = 45
                Cyan = 106
                DarkCyan = 46
                Gray = 47
                DarkGray = 100
            }
            style = [pscustomobject][ordered]@{
                RESET = 0
                BOLD_ON = 1
                ITALIC_ON = 3
                UNDERLINE_ON = 4
                BLINK_ON = 5
                REVERSE_ON = 7
                # BOLD_OFF = 22
                # ITALIC_OFF = 23
                # UDERLINE_OFF = 24
                # BLINK_OFF = 25
                # REVERSE_OFF = 27
            }
        }
        function Get-ColorizeText {
            <#
                .SYNOPSIS
                    Adds ANSI SGR codes to a string.
                .DESCRIPTION
                    Adds ANSI SGR codes to a string.
                .PARAMETER text
                    Text to be transformed.
                .PARAMETER ansiSgrCode
                    ANSI SGR number to insert.
                    See https://en.wikipedia.org/wiki/ANSI_escape_code for details
                    Or use the [AnsiColor] enum.

                    Also accepts an array of SGR numbers, and will apply all of them.
                .NOTES
                    Designed to play nicely with https://wiki.jenkins-ci.org/display/JENKINS/AnsiColor+Plugin
                .EXAMPLE
                    Get-ColorizeText 'toto' 7,93,101
            #>
            param(
                $object,
                [int[]]$ansiCodes #https://en.wikipedia.org/wiki/ANSI_escape_code#graphics
            )
            return "$([char]27)[$($ansiCodes -join(';'))m$object$([char]27)[0m"
        }

    $ansiCodes = @()

    if($style){
        $ansiCodes += $AnsiColor.style.$style
    }
    if($foregroundColor){
        $ansiCodes += $AnsiColor.ForeGround.$foregroundColor
    }
    if($backgroundColor) {
        $ansiCodes += $AnsiColor.BackGround.$backgroundColor
    }

    # Write-HostOriginal (Get-ColorizeText $object -ansiCodes $ansiCodes ) -nonewline # | Out-Host
    # (Get-ColorizeText $object -ansiCodes $ansiCodes ) | Out-Host
    # [Console]::Write( (Get-ColorizeText $object -ansiCodes $ansiCodes ) )
    if($foregroundColor -and $backgroundColor){
        # Write-HostOriginal (Get-ColorizeText $object -ansiCodes $ansiCodes ) -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor -nonewline # | Out-Host
        $global:ConsoleOutput += (Get-ColorizeText $object -ansiCodes $ansiCodes )
    } elseif($foregroundColor){
        # Write-HostOriginal (Get-ColorizeText $object -ansiCodes $ansiCodes ) -ForegroundColor $foregroundColor -nonewline # | Out-Host
        $global:ConsoleOutput += (Get-ColorizeText $object -ansiCodes $ansiCodes )
    } elseif($backgroundColor){
        # Write-HostOriginal (Get-ColorizeText $object -ansiCodes $ansiCodes ) -BackgroundColor $backgroundColor -nonewline # | Out-Host
        $global:ConsoleOutput += (Get-ColorizeText $object -ansiCodes $ansiCodes )
    } else {
        # Write-HostOriginal $object -nonewline # | Out-Host
        $global:ConsoleOutput += $object
    }
    if (!$nonewline) {
        Write-HostOriginal $global:ConsoleOutput # -NoNewline
        $global:ConsoleOutput = ''
        # Write-HostOriginal '$!' -fore magenta 
    }
}