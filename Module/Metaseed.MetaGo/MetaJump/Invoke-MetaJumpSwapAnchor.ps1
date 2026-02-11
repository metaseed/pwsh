function Invoke-MetaJumpSwapAnchor {
    [CmdletBinding()]
    param()

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    # No selection, nothing to do
    if ($selectionStart -eq -1 -or $selectionLength -le 0) {
        return
    }

    # Swap _current(cursor) and mark (anchor), then bump selection counter to keep visual selection alive
    [Microsoft.PowerShell.PSConsoleReadLine]::ExchangePointAndMark($null, $null)
    #  The SelectForwardChar + SelectBackwardChar pair is a no-op on the cursor position but increments _visualSelectionCommandCount to prevent the selection from being cleared on the next render cycle (since the key dispatch decrements it).
    [Microsoft.PowerShell.PSConsoleReadLine]::SelectForwardChar($null, $null)
    [Microsoft.PowerShell.PSConsoleReadLine]::SelectBackwardChar($null, $null)
}
