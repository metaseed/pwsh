function Write-BufferText {
    param($BufferInfo)
    # Handle CRLF: remove CR so it doesn't mess up cursor position logic
    ## NOTE: we should not add -1 to -split like below, otherwise we only return 1 element in $lines
    # $lines = ($BufferInfo.Line -replace "`r", "") -split "`n" , -1
    $lines = ($BufferInfo.Line -replace "`r", "") -split "`n"
    # $dbg = @{ContinueWidth=$BufferInfo.ContinuationPromptWidth; Line = "" ;Lines = $lines.Count }
    $esc = [char]0x1b
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($i -eq 0) {
            if ($BufferInfo.StartTop -ge 0) {
                [Console]::SetCursorPosition($BufferInfo.StartLeft, $BufferInfo.StartTop)
                # $dbg.Line += "$($BufferInfo.StartLeft):$($BufferInfo.StartTop}, "
            }
        }
        else {
            $y = [Console]::CursorTop
            if ([Console]::CursorLeft -gt 0 -or $lines[$i - 1].Length -eq 0) {
                $y++
            }
            if ($y -lt [Console]::BufferHeight) {
                [Console]::SetCursorPosition($BufferInfo.ContinuationPromptWidth, $y)
            }
            # $dbg.Line += "${Info.ContinuationPromptWidth}:$y}, "
        }
        # $dbg.Line += $lines[$i]
        # $dbg.Line+= "`n"
        # if the code is show outside the end of line, i.e. for multiple char code, how to clear it, the write will not override the virsual
        # with clear to end of line
        [Console]::Write($lines[$i] + "$esc[K")
    }
    # Show-ObjAsTooltip -BufferInfo $BufferInfo -Obj $dbg
}

function Reset-View {
    param($BufferInfo)
    # Clean Slate (Restore Line Text)
    # We must restore original text to clear previous overlays
    Write-BufferText -BufferInfo $BufferInfo
}
function Restore-Visuals {
    param($BufferInfo)

    # 1. Clear overlays by overwriting with original plain text
    $currentLeft = [Console]::CursorLeft
    $currentTop = [Console]::CursorTop

    Write-BufferText -BufferInfo $BufferInfo

    # 2. Restore cursor and force PSReadLine to refresh (restore syntax highlighting)
    [Console]::SetCursorPosition($currentLeft, $currentTop)
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("")
}

function Draw-Overlay {
    param($BufferInfo, $Matches, $Codes, $FilterLength, $Config, $isRipple = $true)

    if ( $Matches.Count -eq 0 -or $Codes.Count -eq 0) {
        return
    }

    Reset-View -BufferInfo $BufferInfo
    # Reconstruct the line with visual indicators
    $esc = [char]0x1b
    $reset = "${esc}[0m"

    # We need to map linear index to (Left, Top)
    $GetPos = {
        param($idx)

        $offset = Get-VisualOffset -Line $BufferInfo.Line -Index $idx -StartLeft $BufferInfo.StartLeft -BufferWidth  $BufferInfo.ConsoleWidth -ContinuationPromptWidth $BufferInfo.ContinuationPromptWidth
        return @{ X = $offset.X; Y = $BufferInfo.StartTop + $offset.Y }
    }

    $filterLen = $FilterLength

    # 1. Draw Backgrounds (Filter + Next)
    foreach ($idx in $Matches) {
        $pos = &$GetPos $idx

        # Draw Filtered Text
        if ($filterLen -gt 0) {
            $txt = $BufferInfo.Line.Substring($idx, $filterLen)
            # Using Underline (4)
            $ansi = "${esc}[4m$txt$reset"
            [Console]::SetCursorPosition($pos.X, $pos.Y)
            [Console]::Write($ansi)
        }

        if ($isRipple) {
            # Draw Next Char
            $nextIdx = $idx + $filterLen
            if ($nextIdx -lt $BufferInfo.Line.Length) {
                $nextPos = &$GetPos $nextIdx
                $nextChar = $BufferInfo.Line[$nextIdx]
                # Using Italics (3)
                $ansi = "${esc}[3m$nextChar$reset"
                [Console]::SetCursorPosition($nextPos.X, $nextPos.Y)
                [Console]::Write($ansi)
            }
        }
    }

    # 2. Draw Codes (On top)
    for ($i = 0; $i -lt $Matches.Count; $i++) {
        $idx = $Matches[$i]
        $code = $Codes[$i]
        $pos = &$GetPos $idx

        # Pre-calculate ANSI codes
        $bgName = $Config.CodeBackgroundColors[$code.Length - 1] ?? $Config.CodeBackgroundColors[-1]
        $bgColor = Get-AnsiColor -Name $bgName -IsBg $true

        $ansi = "${esc}[$($bgColor)m${esc}[30m$code$reset" # foreground is black
        # $ansi = "${esc}[$($bgColor)m$code$reset" # foreground is white

        [Console]::SetCursorPosition($pos.X, $pos.Y)
        [Console]::Write($ansi)
    }

}