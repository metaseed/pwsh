using namespace System.Management.Automation
using namespace System.Collections.Generic

function Get-BufferInfo {
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    
    $consoleLeft = [Console]::CursorLeft
    $consoleTop = [Console]::CursorTop
    
    $startLeft = $consoleLeft - $cursor
    $startTop = $consoleTop

    while ($startLeft -lt 0) {
        $startLeft += [Console]::BufferWidth
        $startTop--
    }

    return @{
        Line = $line
        Cursor = $cursor
        ConsoleLeft = $consoleLeft
        ConsoleTop = $consoleTop
        StartLeft = $startLeft
        StartTop = $startTop
    }
}

function Show-Tooltip {
    param($Top)
    
    $tooltip = "please type the char to jump to..."
    
    if ($Top -lt [Console]::BufferHeight) {
        [Console]::SetCursorPosition(0, $Top)
        $originalColor = [Console]::ForegroundColor
        [Console]::ForegroundColor = 'Cyan'
        [Console]::Write($tooltip)
        [Console]::ForegroundColor = $originalColor
    }
    return $tooltip.Length
}

function Clear-Tooltip {
    param($Top, $Length)
    
    if ($Top -lt [Console]::BufferHeight) {
        [Console]::SetCursorPosition(0, $Top)
        [Console]::Write(" " * $Length)
    }
}

function Show-Indicator {
    param($Info)
    
    [Console]::SetCursorPosition($Info.ConsoleLeft, $Info.ConsoleTop)
    $indicatorChar = ' '
    if ($Info.Cursor -lt $Info.Line.Length) {
        $indicatorChar = $Info.Line[$Info.Cursor]
    }
    
    $prevBg = [Console]::BackgroundColor
    $prevFg = [Console]::ForegroundColor
    
    [Console]::BackgroundColor = 'Green'
    [Console]::ForegroundColor = 'Black'
    [Console]::Write($indicatorChar)
    
    [Console]::BackgroundColor = $prevBg
    [Console]::ForegroundColor = $prevFg
    [Console]::SetCursorPosition($Info.ConsoleLeft, $Info.ConsoleTop)
    
    return @{ Char = $indicatorChar; Bg = $prevBg; Fg = $prevFg }
}

function Restore-Indicator {
    param($Info, $SavedState)
    
    [Console]::SetCursorPosition($Info.ConsoleLeft, $Info.ConsoleTop)
    [Console]::BackgroundColor = $SavedState.Bg
    [Console]::ForegroundColor = $SavedState.Fg
    [Console]::Write($SavedState.Char)
    [Console]::SetCursorPosition($Info.ConsoleLeft, $Info.ConsoleTop)
}

function Get-CharMatches {
    param($Line, $Char)
    
    $matches = @()
    for ($i = 0; $i -lt $Line.Length; $i++) {
        if ($Line[$i] -eq $Char) {
            $matches += $i
        }
    }
    return $matches
}

function Get-ColorMap {
    return @(
        @{ Key = 'g'; Color = "42"; Label = "Green" }
        @{ Key = 'w'; Color = "47"; Label = "White" }
        @{ Key = 'r'; Color = "41"; Label = "Red" }
        @{ Key = 'b'; Color = "44"; Label = "Blue" }
        @{ Key = 'c'; Color = "46"; Label = "Cyan" }
        @{ Key = 'y'; Color = "43"; Label = "Yellow" }
        @{ Key = 'm'; Color = "45"; Label = "Magenta" }
    )
}

function Draw-Overlay {
    param($Info, $Matches, $ColorMap)
    
    $overlayParts = @()
    $lastIndex = 0
    $matchIndex = 0

    foreach ($idx in $Matches) {
        if ($idx -gt $lastIndex) {
            $overlayParts += $Info.Line.Substring($lastIndex, $idx - $lastIndex)
        }
        
        if ($matchIndex -lt $ColorMap.Count) {
            $map = $ColorMap[$matchIndex]
            $esc = [char]0x1b
            $coloredChar = "$esc[$($map.Color)m$($Info.Line[$idx])$esc[0m"
            $overlayParts += $coloredChar
        } else {
            $overlayParts += $Info.Line[$idx]
        }
        
        $lastIndex = $idx + 1
        $matchIndex++
    }
    
    if ($lastIndex -lt $Info.Line.Length) {
        $overlayParts += $Info.Line.Substring($lastIndex)
    }

    $overlayString = $overlayParts -join ""
    
    [Console]::SetCursorPosition($Info.StartLeft, $Info.StartTop)
    [Console]::Write($overlayString)
}

function Restore-Visuals {
    param($Info)
    
    # Force PSReadLine to refresh. 
    # Logic requires cursor to be at the correct calculated physical position for the current buffer cursor.
    
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    $finalLeft = $Info.StartLeft + $cursor
    $finalTop = $Info.StartTop
    
    while ($finalLeft -ge [Console]::BufferWidth) {
        $finalLeft -= [Console]::BufferWidth
        $finalTop++
    }

    [Console]::SetCursorPosition($finalLeft, $finalTop)
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("")
}

function Invoke-MetaJump {
    [CmdletBinding()]
    param()

    $info = Get-BufferInfo
    $cursorVisible = [Console]::CursorVisible
    [Console]::CursorVisible = $false
    
    try {
        # 1. Show Visual Cues
        $tooltipTop = $info.ConsoleTop + 1
        $tooltipLen = Show-Tooltip -Top $tooltipTop
        $indicatorState = Show-Indicator -Info $info
        
        # 2. Read Target
        $targetKey = [Console]::ReadKey($true)
        
        # 3. Cleanup Immediate Visuals
        Clear-Tooltip -Top $tooltipTop -Length $tooltipLen
        Restore-Indicator -Info $info -SavedState $indicatorState
        
        if ($targetKey.Key -eq 'Escape') { return }
        
        $targetChar = $targetKey.KeyChar
        
        # 4. Find Matches
        $matches = Get-CharMatches -Line $info.Line -Char $targetChar
        if ($matches.Count -eq 0) { return }
        
        # 5. Draw Overlay
        $colorMap = Get-ColorMap
        Draw-Overlay -Info $info -Matches $matches -ColorMap $colorMap
        
        # 6. Select Jump Target
        $selectionKey = [Console]::ReadKey($true)
        if ($selectionKey.Key -eq 'Escape') { return }
        
        $selectedMatchIndex = -1
        for ($k = 0; $k -lt $colorMap.Count; $k++) {
            if ("$($colorMap[$k].Key)" -eq "$($selectionKey.KeyChar)") {
                $selectedMatchIndex = $k
                break
            }
        }

        if ($selectedMatchIndex -ge 0 -and $selectedMatchIndex -lt $matches.Count) {
            $newCursorPos = $matches[$selectedMatchIndex]
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($newCursorPos)
        }
    }
    finally {
        [Console]::CursorVisible = $cursorVisible
        Restore-Visuals -Info $info
    }
}

Export-ModuleMember -Function Invoke-MetaJump