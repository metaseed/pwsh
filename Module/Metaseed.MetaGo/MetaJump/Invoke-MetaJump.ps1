using namespace System.Management.Automation
using namespace System.Collections.Generic
. $PSScriptRoot\_lib\Tooltip.ps1
. $PSScriptRoot\_lib\start-indicator.ps1
. $PSScriptRoot\_lib\encorder.ps1

# Configuration
$MetaJumpConfig = @{
    CodeChars                 = "k, j, d, f, l, s, a, h, g, i, o, n, u, r, v, c, w, e, x, m, b, p, q, t, y, z" -split ',' | ForEach-Object { $_.Trim() }
    # only appears as one char decoration codes
    AdditionalSingleCodeChars = "J,D,F,L,A,H,G,I,N,R,E,M,B,Q,T,Y, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0" -split ',' | ForEach-Object { $_.Trim() }
    # bgColors for one-length code, two-length code, 3-length code, ect..
    # if the code length is larger than the array length, the last color is used
    CodeBackgroundColors      = @("Yellow", "Blue", "Cyan", "Magenta")
    TooltipText               = "Jump: type target char..."
}


function Get-VisualOffset {
    param($Line, $Index, $StartLeft, $BufferWidth, $ContinuationPromptWidth = 0)

    $x = $StartLeft
    $y = 0

    for ($i = 0; $i -lt $Index; $i++) {
        $c = $Line[$i]
        if ($c -eq "`n") {
            $x = $ContinuationPromptWidth
            $y++
        }
        elseif ($c -eq "`r") {
            $x = 0
        }
        else {
            $x++
            if ($x -ge $BufferWidth) {
                $x = 0
                $y++
            }
        }
    }
    # x: 0-based, from left of console include continuation prompt for seconde line and after
    # y: 0-based, from top of buffer
    return @{ X = $x; Y = $y }
}

function Get-BufferInfo {
    # string
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    $consoleLeft = [Console]::CursorLeft
    $consoleTop = [Console]::CursorTop
    $bufferWidth = [Console]::BufferWidth # window width in chars
    $continuationPromptWidth = (Get-PSReadLineOption).ContinuationPrompt.Length

    # Check for newlines before cursor
    $substring = $line.Substring(0, $cursor)
    if ($substring.Contains("`n")) {
        # Temporarily move to start to get the prompt width
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0)
        $startLeft = [Console]::CursorLeft
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor)

        $offset = Get-VisualOffset -Line $line -Index $cursor -StartLeft $startLeft -BufferWidth $bufferWidth -ContinuationPromptWidth $continuationPromptWidth
        $startTop = $consoleTop - $offset.Y
    }
    else {
        $startLeft = $consoleLeft - $cursor
        $startTop = $consoleTop

        # Adjust if wrapped
        while ($startLeft -lt 0) {
            $startLeft += $bufferWidth
            $startTop--
        }
    }

    return @{
        Line                    = $line # line text include '\n'
        Cursor                  = $cursor # cursor x position in the whole text, 0-based
        ConsoleLeft             = $consoleLeft # cursor x position in console 0-based
        ConsoleTop              = $consoleTop # cursor y position in console 0-based
        ConsoleWidth            = $bufferWidth # window width in chars, always same if window is not resized
        StartLeft               = $startLeft # the buffer's fist line's x position, 0-based
        StartTop                = $startTop # the buffer's fist line's y position, 0-based
        ContinuationPromptWidth = $continuationPromptWidth # width of '>> ' be default
    }
}

# enter key is used as ripple stopping key, so we don't need to avoid following char conflict for the wave
enum ForegroundColorAnsi {
    Black = 30 # 0x1E 0b0001 1110
    Red = 31
    Green = 32
    Yellow = 33
    Blue = 34
    Magenta = 35
    Cyan = 36
    LightGray = 37
    #38: forground for 8 or 256bits

    DarkGray = 90 # 0x5A 0b0101 1010
    LightRed = 91
    LightGreen = 92
    LightYellow = 93
    LightBlue = 94
    LightMagenta = 95
    LightCyan = 96
    White = 97
}

# for 16colors
enum BackgroundColorAnsi {
    Black = 40 # 0x28 0b0010 1000
    Red = 41 # 0x29 0b0010 1001
    Green = 42
    Yellow = 43
    Blue = 44
    Magenta = 45
    Cyan = 46
    LightGray = 47
    #48: backround for 8 or 256bits;folowwing parameters give details; 2: 256bits; 5: 8bits;

    DarkGray = 100 # 0x64 0b0110 1000
    LightRed = 101 # 0x65 0b0110 1001
    LightGreen = 102
    LightYellow = 103
    LightBlue = 104
    LightMagenta = 105
    LightCyan = 106
    White = 107
}
function Get-AnsiColor {
    param($Name, $IsBg = $false)

    if ($IsBg) {
        return [int][BackgroundColorAnsi]$Name
    }
    else {
        return [int][ForegroundColorAnsi]$Name
    }
}
function Draw-Overlay {
    param($BufferInfo, $Matches, $Codes, $FilterLength, $Config, $isRipple = $true)

    if ( $Matches.Count -eq 0 -or $Codes.Count -eq 0) {
        return
    }

    Reset-View -BufferInfo $BufferInfo
    # Reconstruct the line with visual indicators
    $esc = [char]0x1b
    $reset = "${esc}[0m"

    # We need to map linear index to (Left, Top)
    $GetPos = {
        param($idx)

        $offset = Get-VisualOffset -Line $BufferInfo.Line -Index $idx -StartLeft $BufferInfo.StartLeft -BufferWidth  $BufferInfo.ConsoleWidth -ContinuationPromptWidth $BufferInfo.ContinuationPromptWidth
        return @{ X = $offset.X; Y = $BufferInfo.StartTop + $offset.Y }
    }

    $filterLen = $FilterLength

    # 1. Draw Backgrounds (Filter + Next)
    foreach ($idx in $Matches) {
        $pos = &$GetPos $idx

        # Draw Filtered Text
        if ($filterLen -gt 0) {
            $txt = $BufferInfo.Line.Substring($idx, $filterLen)
            # Using Underline (4)
            $ansi = "${esc}[4m$txt$reset"
            [Console]::SetCursorPosition($pos.X, $pos.Y)
            [Console]::Write($ansi)
        }

        if ($isRipple) {
            # Draw Next Char
            $nextIdx = $idx + $filterLen
            if ($nextIdx -lt $BufferInfo.Line.Length) {
                $nextPos = &$GetPos $nextIdx
                $nextChar = $BufferInfo.Line[$nextIdx]
                # Using Italics (3)
                $ansi = "${esc}[3m$nextChar$reset"
                [Console]::SetCursorPosition($nextPos.X, $nextPos.Y)
                [Console]::Write($ansi)
            }
        }
    }

    # 2. Draw Codes (On top)
    for ($i = 0; $i -lt $Matches.Count; $i++) {
        $idx = $Matches[$i]
        $code = $Codes[$i]
        $pos = &$GetPos $idx

        # Pre-calculate ANSI codes
        $bgName = $Config.CodeBackgroundColors[$code.Length - 1] ?? $Config.CodeBackgroundColors[-1]
        $bgColor = Get-AnsiColor -Name $bgName -IsBg $true

        $ansi = "${esc}[$($bgColor)m${esc}[30m$code$reset" # foreground is black
        # $ansi = "${esc}[$($bgColor)m$code$reset" # foreground is white

        [Console]::SetCursorPosition($pos.X, $pos.Y)
        [Console]::Write($ansi)
    }

}

function Write-BufferText {
    param($BufferInfo)
    # Handle CRLF: remove CR so it doesn't mess up cursor position logic
    ## NOTE: we should not add -1 to -split like below, otherwise we only return 1 element in $lines
    # $lines = ($BufferInfo.Line -replace "`r", "") -split "`n" , -1
    $lines = ($BufferInfo.Line -replace "`r", "") -split "`n"
    # $dbg = @{ContinueWidth=$BufferInfo.ContinuationPromptWidth; Line = "" ;Lines = $lines.Count }
    $esc = [char]0x1b
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($i -eq 0) {
            [Console]::SetCursorPosition($BufferInfo.StartLeft, $BufferInfo.StartTop)
            # $dbg.Line += "$($BufferInfo.StartLeft):$($BufferInfo.StartTop}, "
        }
        else {
            $y = [Console]::CursorTop
            if ([Console]::CursorLeft -gt 0 -or $lines[$i - 1].Length -eq 0) { $y++ }
            [Console]::SetCursorPosition($BufferInfo.ContinuationPromptWidth, $y)
            # $dbg.Line += "${Info.ContinuationPromptWidth}:$y}, "
        }
        # $dbg.Line += $lines[$i]
        # $dbg.Line+= "`n"
        # if the code is show outiside the end of line, i.e. for multiple char code, how to clear it, the write will not override the virsual
        # with clear to end of line
        [Console]::Write($lines[$i] + "$esc[K")
    }
    # Show-ObjAsTooltip -BufferInfo $BufferInfo -Obj $dbg
}

function Show-ObjAsTooltip {
    param($BufferInfo, $Obj)
    $endOffset = Get-VisualOffset -Line $BufferInfo.Line -Index $BufferInfo.Line.Length -StartLeft $BufferInfo.StartLeft -BufferWidth $BufferInfo.ConsoleWidth -ContinuationPromptWidth $BufferInfo.ContinuationPromptWidth
    $tooltipTop = $BufferInfo.StartTop + $endOffset.Y + 1
    $tooltipLen = Show-Tooltip -Top $tooltipTop -Text ($Obj | ConvertTo-Json -Compress)
    return $tooltipLen
}

function Get-TargetChar {
    param($BufferInfo, $icon = "", $toolTip = "")
    # write-host "Get-TargetChar: icon='$icon', tooltip='$toolTip'"
    try {
        if ($toolTip) {
            $endOffset = Get-VisualOffset -Line $BufferInfo.Line -Index $BufferInfo.Line.Length -StartLeft $BufferInfo.StartLeft -BufferWidth $BufferInfo.ConsoleWidth -ContinuationPromptWidth $BufferInfo.ContinuationPromptWidth
            $tooltipTop = $BufferInfo.StartTop + $endOffset.Y + 1
            $tooltipLen = Show-Tooltip $tooltipTop  $toolTip
        }
        if ($icon) {
            $startIndicator = Show-StartIndicator $BufferInfo  $icon
        }
        $key = [Console]::ReadKey($true)
    }
    catch {
        throw $_
    }
    finally {
        if ($toolTip) {
            Clear-Tooltip -Top $tooltipTop -Length $tooltipLen
        }
        if ($icon) {
            # Restore start indicator before drawing overlay
            Restore-StartIndicator $BufferInfo  $startIndicator
        }
    }
    return $key
}

function Reset-View {
    param($BufferInfo)
    # Clean Slate (Restore Line Text)
    # We must restore original text to clear previous overlays
    Write-BufferText -BufferInfo $BufferInfo
}
function Restore-Visuals {
    param($BufferInfo)

    # 1. Clear overlays by overwriting with original plain text
    $currentLeft = [Console]::CursorLeft
    $currentTop = [Console]::CursorTop

    Write-BufferText -BufferInfo $BufferInfo

    # 2. Restore cursor and force PSReadLine to refresh (restore syntax highlighting)
    [Console]::SetCursorPosition($currentLeft, $currentTop)
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("")
}

function Get-ExactMatchIndex {
    param($Codes, $Matches, $InputCode)
    for ($i = 0; $i -lt $Codes.Count; $i++) {
        if ($Codes[$i] -eq $InputCode) {
            return $Matches[$i]
        }
    }
    return -1
}

function Test-PartialMatch {
    param($Codes, $InputCode)
    foreach ($c in $Codes) {
        if ($c.StartsWith($InputCode)) {
            return $true
        }
    }
    return $false
}
# returns array of match start indexes, 0-based
function Get-Matches {
    param(
        [string]$Line,
        [string]$TargetFilterText
    )

    if ([string]::IsNullOrEmpty($TargetFilterText)) { return @() }

    $targetMatchIndexes = @()
    $index = 0
    while ($true) {
        $index = $Line.IndexOf($TargetFilterText, $index, [System.StringComparison]::OrdinalIgnoreCase)
        if ($index -eq -1) { break }
        $targetMatchIndexes += $index
        $index++
    }
    return $targetMatchIndexes
}
function Get-ContinueRippleTargets {
    param([string]$inputChar, [string]$BufferText, [int[]]$TargetMatchIndexes, [int]$inputCharOffset<#the filter text length#>)
    if ($null -eq $TargetMatchIndexes -or $TargetMatchIndexes.Count -eq 0) { return Get-Matches $BufferText $inputChar }

    $newTargetMatchIndexes = @()

    foreach ($idx in $TargetMatchIndexes) {
        $nextChar = $BufferText[$idx + $inputCharOffset] # note str[out of range] returns $null
        if ($inputChar -eq $nextChar) {
            $newTargetMatchIndexes += $idx
        }
    }
    return $newTargetMatchIndexes
}

function Ripple {
    param($BufferInfo, $Config)

    $filterText = ""
    $codes = @()
    $TargetMatchIndexes = @()
    $errorMsg = ""

    while ($true) {
        if ($errorMsg) {
            $icon = "⚠️"
            $tooltip = $errorMsg
            $errorMsg = ""
        }
        elseif ($filterText.Length -eq 0) {
            $icon = "🏃"
            $tooltip = "MetaJump: Please type target char to jump..."
        }
        else {
            $icon = "" # no icon
            $tooltip = "MetaJump: Please type code to jump to or continue typing target chars..."
        }
        # write-host "Ripple: icon='$icon', tooltip='$tooltip', filterText='$filterText', codes='$codes"
        $key = Get-TargetChar $BufferInfo  $icon  $tooltip
        if ($key.Key -eq 'Escape') {
            return @()
        }

        if (Test-PartialMatch -Codes $codes -InputCode $key.KeyChar) {
            return @($TargetMatchIndexes, $codes, $filterText.Length, $key)
        }
        else {
            # Find Matches
            $TargetMatchIndexes = Get-ContinueRippleTargets "$($key.KeyChar)" $BufferInfo.Line  $TargetMatchIndexes  $filterText.Length

            if ($TargetMatchIndexes.Count -gt 0) {
                $filterText += $key.KeyChar
            }
            else {
                [Console]::Beep()
                # Backtrack logic or exit?
                # If filtered to 0, maybe revert last char?
                $errorMsg = "MetaJump: No matches for last character"
                continue
            }
        }

        # Generate Codes
        try {
            $codes = Get-JumpCodesForWave -TargetMatchIndexes $TargetMatchIndexes -CodeChars $Config.CodeChars -BufferText $BufferInfo.Line -TargetTextLength $filterText.Length -AdditionalSingleCodeChars $Config.AdditionalSingleCodeChars
        }
        catch {
            $errorMsg = $_.Exception.Message
            continue
        }

        # Draw Overlay
        if ($codes.Count -ne $TargetMatchIndexes.Count) {
            # throw "MetaJump: Code count mismatch: $($codes.Count) != $($TargetMatchIndexes.Count)"
        }
        # $global:_MetaJumpDebug.Ripple = @($TargetMatchIndexes, $codes, $filterText.Length, $BufferInfo, $Config)
        Draw-Overlay -BufferInfo $BufferInfo -Matches $TargetMatchIndexes -Codes $codes -FilterLength $filterText.Length -Config $Config
    }
}

<#
shrink the codes and when only 1 code and match index available, navigate to target location.
if the typing char is not in the starting chars of any code, warning to let user to type the code on screen or 'Esc' to cancel.
#>
function Navigate {
    param($TargetMatchIndexes, $codes, $FilterLength, $BufferInfo, $Config, $InitialKey)

    $guidingInfo = "MetaJump: Type codes to jump to target, or 'Esc' to cancel."
    # info icon
    $icon = "ℹ️"
    $tooltip = $guidingInfo
    $firstLoop = $true

    while ($true) {
        # check if only one match index and code
        if ($codes.Count -eq 1 -and $TargetMatchIndexes.Count -eq 1) {
            # jump to target
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($TargetMatchIndexes[0])
            return
        }
        if ($firstLoop -and $InitialKey) {
            $key = $InitialKey
            $firstLoop = $false
        }
        else {
            $key = Get-TargetChar $BufferInfo $icon $tooltip
            if ($key.Key -eq 'Escape') {
                return @()
            }
            $potentialCode = $key.KeyChar.ToString()
            if (-not (Test-PartialMatch -Codes $codes -InputCode $potentialCode)) {
                [Console]::Beep()
                # no match, warning
                $icon = "⚠️"
                $tooltip = "MetaJump: No matches for last character, please type code on screen or 'Esc' to cancel."
                continue
            }
        }

        # shrink codes
        $newCodes = @()
        $keyChar = $key.KeyChar.ToString()
        $newTargetMatchIndexes = @()
        for ($i = 0; $i -lt $codes.Count; $i++) {
            $c = $codes[$i]
            if ($c.Length -eq 0) {
                if ($c -ceq $keyChar) {
                    $newCodes = @($c)
                    $newTargetMatchIndexes = @($TargetMatchIndexes[$i])
                    break
                }
            }
            else {
                if ($c.StartsWith($keyChar)) {
                    $newTargetMatchIndexes += $TargetMatchIndexes[$i]
                    $newCodes += $c.Substring(1)
                }
            }
        }
        # Show-ObjAsTooltip -BufferInfo $BufferInfo -Obj @{
        #     OldCodes = $codes
        #     NewCodes = $newCodes
        #     OldTargetMatchIndexes = $TargetMatchIndexes
        #     NewTargetMatchIndexes = $newTargetMatchIndexes
        # }

        $TargetMatchIndexes = $newTargetMatchIndexes
        $codes = $newCodes
        Draw-Overlay -BufferInfo $BufferInfo -Matches $TargetMatchIndexes -Codes $codes -FilterLength $FilterLength -Config $Config -isRipple $false
        # reset info icon
        $icon = "ℹ️"
        $tooltip = "" #$guidingInfo

    }
}

function Invoke-MetaJump {
    [CmdletBinding()]
    param()

    $info = Get-BufferInfo

    if ([string]::IsNullOrEmpty($info.Line)) { return }

    $cursorVisible = [Console]::CursorVisible
    [Console]::CursorVisible = $false

    try {
        $res = Ripple $info $MetaJumpConfig
        if ( $res.Count -eq 0) { return } # cancelled

        $initKey = if ($res.Count -ge 4) { $res[3] } else { $null }
        Navigate $res[0] $res[1] $res[2] $info $MetaJumpConfig $initKey
    }
    finally {
        [Console]::CursorVisible = $cursorVisible
        Restore-Visuals $info
    }
}
