using namespace System.Management.Automation
using namespace System.Collections.Generic
. $PSScriptRoot\_lib\Tooltip.ps1

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



function Show-StartIndicator {
    param($Info)

    # the 🏃is 2 char width, so move back 1 char or better ui view
    $drawLeft = if ($Info.ConsoleLeft -gt 0) { $Info.ConsoleLeft - 1 } else { $Info.ConsoleLeft }
    [Console]::SetCursorPosition($drawLeft, $Info.ConsoleTop)
    [Console]::Write("🏃")
    [Console]::SetCursorPosition($Info.ConsoleLeft, $Info.ConsoleTop) # Restore cursor
    return $null
}

function Restore-StartIndicator {
    param($Info, $SavedState)

    $drawLeft = if ($Info.ConsoleLeft -gt 0) { $Info.ConsoleLeft - 1 } else { $Info.ConsoleLeft }
    [Console]::SetCursorPosition($drawLeft, $Info.ConsoleTop)

    # Restore 2 chars (width of runner)
    $startIdx = $Info.Cursor - ($Info.ConsoleLeft - $drawLeft)
    $restoreText = ""
    for ($i = 0; $i -lt 2; $i++) {
        $idx = $startIdx + $i
        if ($idx -ge 0 -and $idx -lt $Info.Line.Length) {
            $restoreText += $Info.Line[$idx]
        } else {
            $restoreText += " "
        }
    }
    [Console]::Write($restoreText)
    [Console]::SetCursorPosition($Info.ConsoleLeft, $Info.ConsoleTop)
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

function Get-AnsiColor {
    param($Name, $IsBg = $false)

    $code = 0
    $isBright = $false

    switch ($Name) {
        'Black' { $code = 0 }
        'Red' { $code = 1 }
        'Green' { $code = 2 }
        'Yellow' { $code = 3 }
        'Blue' { $code = 4 }
        'Magenta' { $code = 5 }
        'Cyan' { $code = 6 }
        'White' { $code = 7 }

        # Extended/Special mappings
        'Gray' { $code = 0; $isBright = $true } # Bright Black
        'DarkGray' { $code = 0; $isBright = $true }
        'DarkCyan' { $code = 6 }

        Default { $code = 7 }
    }

    $base = if ($IsBg) { 40 } else { 30 }
    if ($isBright) { $base += 60 }

    return "$($base + $code)"
}
function Draw-Overlay {
    param($Info, $Matches, $Codes, $FilterText)

    # Reconstruct the line with visual indicators

    $esc = [char]0x1b
    $reset = "${esc}[0m"

    # Pre-calculate ANSI codes
    $bg1 = $MetaJumpConfig.OneCharBackgroundColor
    $bg2 = $MetaJumpConfig.MoreThanOneCharBackgroundColor

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
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
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
        try {
            $endOffset = Get-VisualOffset -Line $info.Line -Index $info.Line.Length -StartLeft $info.StartLeft -BufferWidth ([Console]::BufferWidth) -ContinuationPromptWidth $info.ContinuationPromptWidth
            $tooltipTop = $info.StartTop + $endOffset.Y + 1

            $tooltipLen = Show-Tooltip -Top $tooltipTop -Text $MetaJumpConfig.TooltipText
            $startIndicator = Show-StartIndicator -Info $info
            $key = [Console]::ReadKey($true)
            if ($key.Key -eq 'Escape') { return }
        }
        finally {
            Clear-Tooltip -Top $tooltipTop -Length $tooltipLen
            # Restore start indicator before drawing overlay
            Restore-StartIndicator -Info $info -SavedState $startIndicator
        }

        $filterText = "$($key.KeyChar)"
        $currentCodeInput = ""

        # 3. Loop
        while ($true) {
            # Clean Slate (Restore Line Text)
            # We must restore original text to clear previous overlays
            [Console]::SetCursorPosition($info.StartLeft, $info.StartTop)
            [Console]::Write($info.Line)

            # Find Matches
            $matches = Get-Matches -Line $info.Line -FilterText $filterText
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
            $codes = Get-JumpCodes -Count $matches.Count -Charset $MetaJumpConfig.CodeChars

            # Draw Overlay
            Draw-Overlay -Info $info -Matches $matches -Codes $codes -FilterText $filterText -Config $MetaJumpConfig

            # Wait for Selection / Filter
            $key = [Console]::ReadKey($true)
            if ($key.Key -eq 'Escape') { return }
            $inputChar = $key.KeyChar

            $potentialCode = $currentCodeInput + $inputChar

            # Check for Exact Match
            $jumpIndex = -1
            for ($i = 0; $i -lt $codes.Count; $i++) {
                if ($codes[$i] -eq $potentialCode) {
                    $jumpIndex = $matches[$i]
                    break
                }
            }

            if ($jumpIndex -ne -1) {
                # Jump!
                [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($jumpIndex)
                return
            }

            # Check for Partial Match
            $isPartial = $false
            foreach ($c in $codes) {
                if ($c.StartsWith($potentialCode)) {
                    $isPartial = $true
                    break
                }
            }

            if ($isPartial) {
                $currentCodeInput = $potentialCode
                continue # Wait for next char to complete code
            }

            # Not a code match (full or partial) -> Treat as filter
            $currentCodeInput = "" # Reset partial code
            $filterText += $inputChar
        }
    }
    finally {
        [Console]::CursorVisible = $cursorVisible
        Restore-Visuals -Info $info
    }
}
