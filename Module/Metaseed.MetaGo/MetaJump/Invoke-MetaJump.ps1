using namespace System.Management.Automation
using namespace System.Collections.Generic

. $PSScriptRoot\_lib\AnsiUtils.ps1
. $PSScriptRoot\_lib\Tooltip.ps1
. $PSScriptRoot\_lib\start-indicator.ps1
. $PSScriptRoot\_lib\encoder.ps1
. $PSScriptRoot\_lib\visual.ps1

# Configuration
$MetaJumpConfig = @{
    CodeChars                 = "k, j, d, f, l, s, a, h, g, i, o, n, u, r, v, c, w, e, x, m, b, p, q, t, y, z" -split ',' | ForEach-Object { $_.Trim() }
    # only appears as one char decoration codes
    AdditionalSingleCodeChars = "J,D,F,L,A,H,G,I,N,R,E,M,B,Q,T,Y, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0" -split ',' | ForEach-Object { $_.Trim() }
    # bgColors for one-length code, two-length code, 3-length code, ect..
    # if the code length is larger than the array length, the last color is used
    CodeBackgroundColors      = @("Yellow", "Blue", "Cyan", "Magenta")
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
    # y: 0-based, from top of input
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


    $info = @{
        Line                    = $line # line text include '\n'
        Cursor                  = $cursor # cursor x position in the whole text, 0-based
        ConsoleLeft             = $consoleLeft # cursor x position in console 0-based
        ConsoleTop              = $consoleTop # cursor y position in console 0-based
        ConsoleWidth            = $bufferWidth # window width in chars, always same if window is not resized
        StartLeft               = $startLeft # the buffer's fist line's x position, 0-based
        StartTop                = $startTop # the buffer's fist line's y position, 0-based
        ContinuationPromptWidth = $continuationPromptWidth # width of '>> ' be default
    }
    # $global:_MetaJumpDebug.GetBufferInfo = $info
    return $info
}

# enter key is used as ripple stopping key, so we don't need to avoid following char conflict for the wave

function Get-TargetChar {
    param($BufferInfo, $icon = "", $toolTip = "")
    # write-host "Get-TargetChar: icon='$icon', tooltip='$toolTip'"
    try {
        if ($toolTip) {
            $endOffset = Get-VisualOffset -Line $BufferInfo.Line -Index $BufferInfo.Line.Length -StartLeft $BufferInfo.StartLeft -BufferWidth $BufferInfo.ConsoleWidth -ContinuationPromptWidth $BufferInfo.ContinuationPromptWidth
            $tooltipTop = $BufferInfo.StartTop + $endOffset.Y + 1
            Show-Tooltip $tooltipTop  $toolTip
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
            Clear-Tooltip -Top $tooltipTop
        }
        if ($icon) {
            # Restore start indicator before drawing overlay
            Restore-StartIndicator $BufferInfo  $startIndicator
        }
    }
    return $key
}

function Test-PartialMatch {
    param($Codes, $InputCode)
    foreach ($c in $Codes) {
        if ("$c".StartsWith($InputCode)) {
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

        if (($key.Key -eq 'Enter') -or (Test-PartialMatch -Codes $codes -InputCode $key.KeyChar)) {
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
            $codes = Get-JumpCodesForWave -TargetMatchIndexes $TargetMatchIndexes -CodeChars $Config.CodeChars -BufferText $BufferInfo.Line -TargetTextLength $filterText.Length -AdditionalSingleCodeChars $Config.AdditionalSingleCodeChars -CursorIndex $BufferInfo.Cursor
        }
        catch {
            $errorMsg = $_.Exception.Message
            continue
        }

        # Draw Overlay
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
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($TargetMatchIndexes[0]+1<#behind the char#>)
            return
        }
        if ($firstLoop -and $InitialKey -and $InitialKey.Key -ne 'Enter') {
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
        $tooltip = $guidingInfo

    }
}

function Invoke-MetaJump {
    [CmdletBinding()]
    param()

    $info = Get-BufferInfo

    if ([string]::IsNullOrEmpty($info.Line)) {
        return
    }

    $cursorVisible = [Console]::CursorVisible
    [Console]::CursorVisible = $false

    try {
        $res = Ripple -BufferInfo $info -Config $MetaJumpConfig
        if ( $res.Count -eq 0) {
            # cancelled
            return
        }

        Navigate -TargetMatchIndexes $res[0] -Codes $res[1] -FilterLength $res[2] -BufferInfo $info -Config $MetaJumpConfig -InitialKey $res[3]
    }
    finally {
        [Console]::CursorVisible = $cursorVisible
        Restore-Visuals $info
    }
}
