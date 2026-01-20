function Show-Tooltip {
    param($Top, $Text)

    if ($Top -ge [Console]::BufferHeight) {
        return 0
    }

    [Console]::SetCursorPosition(0, $Top)
    $originalColor = [Console]::ForegroundColor
    [Console]::ForegroundColor = 'Cyan'
    [Console]::Write($Text)
    [Console]::ForegroundColor = $originalColor
}

function Clear-Tooltip {
    param($Top)

    if ($Top -lt [Console]::BufferHeight) {
        [Console]::SetCursorPosition(0, $Top)
        # [Console]::Write(" " * $Length)
        [Console]::Write("`e[K")
    }
}

function Show-ObjAsTooltip {
    param($BufferInfo, $Obj)
    $endOffset = Get-VisualOffset -Line $BufferInfo.Line -Index $BufferInfo.Line.Length -StartLeft $BufferInfo.StartLeft -BufferWidth $BufferInfo.ConsoleWidth -ContinuationPromptWidth $BufferInfo.ContinuationPromptWidth
    $tooltipTop = $BufferInfo.StartTop + $endOffset.Y + 1
    $tooltipLen = Show-Tooltip -Top $tooltipTop -Text ($Obj | ConvertTo-Json -Compress)
    return $tooltipLen
}