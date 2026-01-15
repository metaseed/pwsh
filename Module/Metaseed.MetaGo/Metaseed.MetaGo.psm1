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

    # 3. Read the target char (the char to jump to)
    # We can't use ReadKey($true) easily if we want to support 'Esc' to cancel cleanly
    # without printing chars.
    $targetKey = [Console]::ReadKey($true)

    if ($targetKey.Key -eq 'Escape') { return }

    $targetChar = $targetKey.KeyChar

    # 4. Find all occurrences
    $matches = @()
    for ($i = 0; $i -lt $line.Length; $i++) {
        if ($line[$i] -eq $targetChar) {
            $matches += $i
        }
    }

    if ($matches.Count -eq 0) { return }

    # 5. Assign Colors/Keys
    # Order: Green, White, Red, Blue, Cyan, Yellow, Magenta
    $colorMap = @(
        @{ Key = 'g'; Color = "42"; Label = "Green" }
        @{ Key = 'w'; Color = "47"; Label = "White" }
        @{ Key = 'r'; Color = "41"; Label = "Red" }
        @{ Key = 'b'; Color = "44"; Label = "Blue" }
        @{ Key = 'c'; Color = "46"; Label = "Cyan" }
        @{ Key = 'y'; Color = "43"; Label = "Yellow" }
        @{ Key = 'm'; Color = "45"; Label = "Magenta" }
    )

    # 6. Construct Overlay String
    # We will rebuild the string with ANSI codes.
    # Warning: This is complex if we have existing ANSI codes (syntax highlighting).
    # For MVP, we assume the buffer text is plain text and we apply our own highlighting.

    $overlayParts = @()
    $lastIndex = 0
    $matchIndex = 0

    foreach ($idx in $matches) {
        # Append text before match
        if ($idx -gt $lastIndex) {
            $overlayParts += $line.Substring($lastIndex, $idx - $lastIndex)
        }

        # Apply Color to the match
        if ($matchIndex -lt $colorMap.Count) {
            $map = $colorMap[$matchIndex]
            # ANSI: Esc [ <BgColor> m <Char> Esc [ 0 m
            # We use `e for Esc in PowerShell, but [char]0x1b is safer in older versions
            $esc = [char]0x1b
            $coloredChar = "$esc[$($map.Color)m$($line[$idx])$esc[0m"
            $overlayParts += $coloredChar
        }
        else {
            # Run out of colors/keys
            $overlayParts += $line[$idx]
        }

        $lastIndex = $idx + 1
        $matchIndex++
    }

    # Append remaining text
    if ($lastIndex -lt $line.Length) {
        $overlayParts += $line.Substring($lastIndex)
    }

    $overlayString = $overlayParts -join ""

    # 7. Draw Overlay
    # We need to move cursor to start of input and write.
    [Console]::SetCursorPosition($startLeft, $startTop)
    [Console]::Write($overlayString)

    # Hide cursor during selection
    $cursorVisible = [Console]::CursorVisible
    [Console]::CursorVisible = $false

    try {
        # 8. Wait for Selection
        $selectionKey = [Console]::ReadKey($true)

        if ($selectionKey.Key -eq 'Escape') {
            # Restore visual is handled in finally
            return
        }

        # Find which match was selected
        $selectedMatchIndex = -1
        for ($k = 0; $k -lt $colorMap.Count; $k++) {
            if ("$($colorMap[$k].Key)" -eq "$($selectionKey.KeyChar)") {
                # Case sensitive? user prompt implies lower case keys
                $selectedMatchIndex = $k
                break
            }
        }

        if ($selectedMatchIndex -ge 0 -and $selectedMatchIndex -lt $matches.Count) {
            # 9. Perform Jump
            $newCursorPos = $matches[$selectedMatchIndex]
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($newCursorPos)
        }
    }
    finally {
        # 10. Restore Visuals
        [Console]::CursorVisible = $cursorVisible

        # Force PSReadLine to refresh the line state (restoring syntax highlighting)
        # We do this by inserting an empty string, which triggers a render cycle.
        # We must ensure we are at the correct cursor position first.

        # If we performed a jump, the internal cursor is updated.
        # If we didn't, it's at the old position.

        # However, the screen might still have our "Colored" characters.
        # We need to ensure the cursor is physically at the PSReadLine logical position
        # before calling Insert, so it updates correctly.
        $line = $null
        $currentCursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$currentCursor)

        # Re-calculate physical position
        $finalLeft = $startLeft + $currentCursor
        $finalTop = $startTop
        while ($finalLeft -ge [Console]::BufferWidth) {
            $finalLeft -= [Console]::BufferWidth
            $finalTop++
        }

        [Console]::SetCursorPosition($finalLeft, $finalTop)

        # Trigger refresh
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("")
    }
}

Export-ModuleMember -Function Invoke-MetaJump
