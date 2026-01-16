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