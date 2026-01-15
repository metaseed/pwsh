using namespace System.Management.Automation
using namespace System.Collections.Generic

function Invoke-MetaJump {
    [CmdletBinding()]
    param()

    # 1. Get Current Buffer State
    $line = $null
    $initialCursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$initialCursor)
    # 2. Prompt for target character
    # We don't want to mess up the screen yet.
    # A simple way is to show a small indicator or just wait.
    # Let's write a small prompt below the current line or just wait.

    # Getting the start position of the input on screen is tricky due to prompt length.
    # We can infer it: CurrentConsolePosition - BufferCursorPosition
    $consoleLeft = [Console]::CursorLeft
    $consoleTop = [Console]::CursorTop

    # Calculate where the input starts (assuming single line prompt for simplicity initially,
    # but robust logic should handle wrapping)
    # This is a naive calculation for the "Start of Input"
    # It might be negative if wrapping occurred.
    # For a robust solution, we might just redraw the whole line from the calculated start.

    $startLeft = $consoleLeft - $initialCursor
    $startTop = $consoleTop

    while ($startLeft -lt 0) {
        $startLeft += [Console]::BufferWidth
        $startTop--
    }

    # Hide cursor during selection
    $cursorVisible = [Console]::CursorVisible
    [Console]::CursorVisible = $false
    
    try {
        # --- 1. Visual Cues (Tooltip & Indicator) ---

        # A. Tooltip on next line
        $tooltip = "please type the char to jump to..."
        $tooltipTop = $consoleTop + 1
        
        # Only show if within buffer height (simple check)
        if ($tooltipTop -lt [Console]::BufferHeight) {
            [Console]::SetCursorPosition(0, $tooltipTop)
            $originalColor = [Console]::ForegroundColor
            [Console]::ForegroundColor = 'Cyan'
            [Console]::Write($tooltip)
            [Console]::ForegroundColor = $originalColor
        }

        # B. Indicator at current cursor (Green background)
        [Console]::SetCursorPosition($consoleLeft, $consoleTop)
        $indicatorChar = ' '
        if ($initialCursor -lt $line.Length) {
            $indicatorChar = $line[$initialCursor]
        }
        $prevBg = [Console]::BackgroundColor
        $prevFg = [Console]::ForegroundColor
        [Console]::BackgroundColor = 'Green'
        [Console]::ForegroundColor = 'Black'
        [Console]::Write($indicatorChar)
        [Console]::BackgroundColor = $prevBg
        [Console]::ForegroundColor = $prevFg
        [Console]::SetCursorPosition($consoleLeft, $consoleTop)

        # --- 2. Read Target Char ---
        $targetKey = [Console]::ReadKey($true)
        
        # --- 3. Cleanup Immediate Visuals ---
        # Clear Tooltip
        if ($tooltipTop -lt [Console]::BufferHeight) {
            [Console]::SetCursorPosition(0, $tooltipTop)
            [Console]::Write(" " * $tooltip.Length)
        }
        
        # Restore Indicator (remove Green highlight)
        [Console]::SetCursorPosition($consoleLeft, $consoleTop)
        [Console]::BackgroundColor = $prevBg
        [Console]::ForegroundColor = $prevFg
        [Console]::Write($indicatorChar)
        [Console]::SetCursorPosition($consoleLeft, $consoleTop)
        
        if ($targetKey.Key -eq 'Escape') { return }
        
        $targetChar = $targetKey.KeyChar
        
        # --- 4. Find Occurrences ---
        $matches = @()
        for ($i = 0; $i -lt $line.Length; $i++) {
            if ($line[$i] -eq $targetChar) {
                $matches += $i
            }
        }

        if ($matches.Count -eq 0) { return }

        # --- 5. Assign Colors ---
        $colorMap = @(
            @{ Key = 'g'; Color = "42"; Label = "Green" }
            @{ Key = 'w'; Color = "47"; Label = "White" }
            @{ Key = 'r'; Color = "41"; Label = "Red" }
            @{ Key = 'b'; Color = "44"; Label = "Blue" }
            @{ Key = 'c'; Color = "46"; Label = "Cyan" }
            @{ Key = 'y'; Color = "43"; Label = "Yellow" }
            @{ Key = 'm'; Color = "45"; Label = "Magenta" }
        )

        # --- 6. Construct Overlay ---
        $overlayParts = @()
        $lastIndex = 0
        $matchIndex = 0

        foreach ($idx in $matches) {
            if ($idx -gt $lastIndex) {
                $overlayParts += $line.Substring($lastIndex, $idx - $lastIndex)
            }
            if ($matchIndex -lt $colorMap.Count) {
                $map = $colorMap[$matchIndex]
                $esc = [char]0x1b
                $coloredChar = "$esc[$($map.Color)m$($line[$idx])$esc[0m"
                $overlayParts += $coloredChar
            } else {
                $overlayParts += $line[$idx]
            }
            $lastIndex = $idx + 1
            $matchIndex++
        }
        if ($lastIndex -lt $line.Length) {
            $overlayParts += $line.Substring($lastIndex)
        }
        $overlayString = $overlayParts -join ""

        # --- 7. Draw Overlay ---
        [Console]::SetCursorPosition($startLeft, $startTop)
        [Console]::Write($overlayString)

        # --- 8. Wait for Selection ---
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
        # --- 9. Restore Visuals (Global Refresh) ---
        [Console]::CursorVisible = $cursorVisible

        # Force PSReadLine refresh
        $line = $null
        $currentCursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$currentCursor)

        $finalLeft = $startLeft + $currentCursor
        $finalTop = $startTop
        while ($finalLeft -ge [Console]::BufferWidth) {
            $finalLeft -= [Console]::BufferWidth
            $finalTop++
        }

        [Console]::SetCursorPosition($finalLeft, $finalTop)
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("")
    }
}

Export-ModuleMember -Function Invoke-MetaJump
