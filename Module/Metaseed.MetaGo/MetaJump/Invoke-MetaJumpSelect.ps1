function Invoke-MetaJumpSelect {
    [CmdletBinding()]
    param()

    $info = Get-BufferInfo

    if ([string]::IsNullOrEmpty($info.Line)) {
        return
    }

    $cursorVisible = [Console]::CursorVisible
    [Console]::CursorVisible = $false

    try {
        $startCursor = $info.Cursor

        $res = Ripple -BufferInfo $info -Config $MetaJumpConfig
        if ($res.Count -eq 0) {
            # cancelled
            return
        }

        Navigate -TargetMatchIndexes $res[0] -Codes $res[1] -FilterLength $res[2] -BufferInfo $info -Config $MetaJumpConfig -InitialKey $res[3]

        # Get the new cursor position after navigation
        $line = $null
        $targetCursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$targetCursor)

        # Select from original position to target
        if ($targetCursor -ne $startCursor) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($startCursor)

            if ($targetCursor -gt $startCursor) {
                for ($i = 0; $i -lt ($targetCursor - $startCursor); $i++) {
                    [Microsoft.PowerShell.PSConsoleReadLine]::SelectForwardChar($null, $null)
                }
            }
            else {
                for ($i = 0; $i -lt ($startCursor - $targetCursor); $i++) {
                    [Microsoft.PowerShell.PSConsoleReadLine]::SelectBackwardChar($null, $null)
                }
            }
        }
    }
    finally {
        [Console]::CursorVisible = $cursorVisible
        Restore-Visuals $info
    }
}
