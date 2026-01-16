using namespace System.Management.Automation
using namespace System.Collections.Generic
. $PSScriptRoot\_lib\Tooltip.ps1
. $PSScriptRoot\_lib\start-indicator.ps1

# Configuration
$MetaJumpConfig = @{
        CodeChars                       = "f,j,d,k,s,l,a,g,h,q,w,e,r,t,y,u,i,o,p,z,x,c,v,b,n,m" -split ',' | ForEach-Object { $_.Trim() }
        OneCharBackgroundColor          = "Yellow"
        MoreThanOneCharBackgroundColor  = "Blue"
        TooltipText                     = "Jump: type target char..."
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
    return @{ X = $x; Y = $y }
}

function Get-BufferInfo {
    # string
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    $consoleLeft = [Console]::CursorLeft
    $consoleTop = [Console]::CursorTop
    $bufferWidth = [Console]::BufferWidth
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
        Line        = $line
        Cursor      = $cursor
        ConsoleLeft = $consoleLeft
        ConsoleTop  = $consoleTop
        StartLeft   = $startLeft
        StartTop    = $startTop
        ContinuationPromptWidth = $continuationPromptWidth
    }
}

function Get-Matches {
    param($Line, $FilterText)

    if ([string]::IsNullOrEmpty($FilterText)) { return @() }

    $matches = @()
    $index = 0
    while ($true) {
        $index = $Line.IndexOf($FilterText, $index, [System.StringComparison]::OrdinalIgnoreCase)
        if ($index -eq -1) { break }
        $matches += $index
        $index++
    }
    return $matches
}

function Get-JumpCodes {
    param($Count, $Charset)

    $codes = @()
    $charsetLen = $Charset.Count

    if ($Count -le $charsetLen) {
        # Single char codes
        for ($i = 0; $i -lt $Count; $i++) {
            $codes += $Charset[$i]
        }
    }
    else {
        # Multi-char codes (2 chars)
        # We need roughly Sqrt(Count) chars for first position if we want balanced tree,
        # or we just iterate.
        # Simple strategy: Use all combinations aa, ab, ac...
        # If Count > N*N, we might need 3 chars, but let's stick to 2 for now or fallback.

        $idx = 0
        foreach ($c1 in $Charset) {
            foreach ($c2 in $Charset) {
                if ($idx -ge $Count) { break }
                $codes += "$c1$c2"
                $idx++
            }
            if ($idx -ge $Count) { break }
        }
    }
    return $codes
}
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
        return [BackgroundColorAnsi]$Name
    } else {
        return [ForegroundColorAnsi]$Name
    }
}
function Draw-Overlay {
    param($Info, $Matches, $Codes, $FilterText, $Config)

    # Reconstruct the line with visual indicators
    $esc = [char]0x1b
    $reset = "${esc}[0m"

    # Pre-calculate ANSI codes
    $bg1 = $Config.OneCharBackgroundColor
    $bg2 = $Config.MoreThanOneCharBackgroundColor

    # We need to map linear index to (Left, Top)
    $GetPos = { param($idx)
        $offset = Get-VisualOffset -Line $Info.Line -Index $idx -StartLeft $Info.StartLeft -BufferWidth ([Console]::BufferWidth) -ContinuationPromptWidth $Info.ContinuationPromptWidth
        return @{ X = $offset.X; Y = $Info.StartTop + $offset.Y }
    }

    $filterLen = $FilterText.Length

    # 1. Draw Backgrounds (Filter + Next)
    foreach ($idx in $Matches) {
        $pos = &$GetPos $idx

        # Draw Filtered Text
        if ($filterLen -gt 0) {
            $txt = $Info.Line.Substring($idx, $filterLen)
            # Using Underline (4)
            $ansi = "${esc}[4m$txt$reset"
            [Console]::SetCursorPosition($pos.X, $pos.Y)
            [Console]::Write($ansi)
        }

        # Draw Next Char
        $nextIdx = $idx + $filterLen
        if ($nextIdx -lt $Info.Line.Length) {
            $nextPos = &$GetPos $nextIdx
            $nextChar = $Info.Line[$nextIdx]
            # Using Italics (3)
            $ansi = "${esc}[3m$nextChar$reset"
            [Console]::SetCursorPosition($nextPos.X, $nextPos.Y)
            [Console]::Write($ansi)
        }
    }

    # 2. Draw Codes (On top)
    for ($i = 0; $i -lt $Matches.Count; $i++) {
        $idx = $Matches[$i]
        $code = $Codes[$i]
        $pos = &$GetPos $idx

        $bg = if ($code.Length -gt 1) { "44" } else { "43" } # Blue (44) or Yellow (43)
        $ansi = "${esc}[$($bg)m${esc}[30m$code$reset"

        [Console]::SetCursorPosition($pos.X, $pos.Y)
        [Console]::Write($ansi)
    }
}

function Restore-Visuals {
    param($Info)

    # 1. Clear overlays by overwriting with original plain text
    $currentLeft = [Console]::CursorLeft
    $currentTop = [Console]::CursorTop

    $lines = $Info.Line -split "`n", -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($i -eq 0) {
            [Console]::SetCursorPosition($Info.StartLeft, $Info.StartTop)
        } else {
            $y = [Console]::CursorTop
            if ([Console]::CursorLeft -gt 0 -or $lines[$i-1].Length -eq 0) { $y++ }
            [Console]::SetCursorPosition($Info.ContinuationPromptWidth, $y)
        }
        [Console]::Write($lines[$i])
    }

    # 2. Restore cursor and force PSReadLine to refresh (restore syntax highlighting)
    [Console]::SetCursorPosition($currentLeft, $currentTop)
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("")
}

function Get-TargetChar {
    param($Info, $Config)

    $endOffset = Get-VisualOffset -Line $Info.Line -Index $Info.Line.Length -StartLeft $Info.StartLeft -BufferWidth ([Console]::BufferWidth) -ContinuationPromptWidth $Info.ContinuationPromptWidth
    $tooltipTop = $Info.StartTop + $endOffset.Y + 1

    try {
        $tooltipLen = Show-Tooltip -Top $tooltipTop -Text $Config.TooltipText
        $startIndicator = Show-StartIndicator -Info $Info
        $key = [Console]::ReadKey($true)
    }
    finally {
        Clear-Tooltip -Top $tooltipTop -Length $tooltipLen
        # Restore start indicator before drawing overlay
        Restore-StartIndicator -Info $Info -SavedState $startIndicator
    }
    return $key
}

function Reset-View {
    param($Info)
    # Clean Slate (Restore Line Text)
    # We must restore original text to clear previous overlays
    [Console]::SetCursorPosition($Info.StartLeft, $Info.StartTop)
    [Console]::Write($Info.Line)
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

function Invoke-JumpLoop {
    param($Info, $InitialChar, $Config)

    $filterText = "$($InitialChar)"
    $currentCodeInput = ""

    while ($true) {
        Reset-View -Info $Info

        # Find Matches
        $matches = Get-Matches -Line $Info.Line -FilterText $filterText
        if ($matches.Count -eq 0) {
            [Console]::Beep()
            # Backtrack logic or exit?
            # If filtered to 0, maybe revert last char?
            if ($filterText.Length -gt 1) {
                $filterText = $filterText.Substring(0, $filterText.Length - 1)
                continue
            }
            else {
                return # Nothing matches start char
            }
        }

        # Generate Codes
        $codes = Get-JumpCodes -Count $matches.Count -Charset $Config.CodeChars

        # Draw Overlay
        Draw-Overlay -Info $Info -Matches $matches -Codes $codes -FilterText $filterText -Config $Config

        # Wait for Selection / Filter
        $key = [Console]::ReadKey($true)
        if ($key.Key -eq 'Escape') { return }
        $inputChar = $key.KeyChar

        $potentialCode = $currentCodeInput + $inputChar

        # Check for Exact Match
        $jumpIndex = Get-ExactMatchIndex -Codes $codes -Matches $matches -InputCode $potentialCode
        if ($jumpIndex -ne -1) {
            # Jump!
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($jumpIndex)
            return
        }

        # Check for Partial Match
        if (Test-PartialMatch -Codes $codes -InputCode $potentialCode) {
            $currentCodeInput = $potentialCode
            continue # Wait for next char to complete code
        }

        # Not a code match (full or partial) -> Treat as filter
        $currentCodeInput = "" # Reset partial code
        $filterText += $inputChar
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
        # 1. Init & Visuals, First Input (Target)
        $key = Get-TargetChar -Info $info -Config $MetaJumpConfig
        if ($null -eq $key -or $key.Key -eq 'Escape') { return }

        Invoke-JumpLoop -Info $info -InitialChar $key.KeyChar -Config $MetaJumpConfig
    }
    finally {
        [Console]::CursorVisible = $cursorVisible
        Restore-Visuals -Info $info
    }
}
