function Show-Tooltip {
    param($Top, $Text)

    if ($Top -ge [Console]::BufferHeight) {
        try {
            [Console]::BufferHeight = $Top + 1
            if ($Top -ge ([Console]::WindowTop + [Console]::WindowHeight)) {
                [Console]::WindowTop = $Top - [Console]::WindowHeight + 1
            }
        }
        catch {
            return 0
        }
    }

    if ($Top -ge [Console]::BufferHeight) {
        return 0
    }

    [Console]::SetCursorPosition(0, $Top)
    $originalColor = [Console]::ForegroundColor
    [Console]::ForegroundColor = 'Cyan'
    [Console]::Write($Text)
    [Console]::ForegroundColor = $originalColor
    return $Text.Length
}


function Clear-Tooltip {
    param($Top, $Length)

    if ($Top -lt [Console]::BufferHeight -and $Length -gt 0) {
        [Console]::SetCursorPosition(0, $Top)
        [Console]::Write(" " * $Length)
    }
}