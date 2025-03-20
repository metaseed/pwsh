# Change working dir in powershell to last dir in lf on exit.
#
# You need to put this file to a folder in $ENV:PATH variable.
#
# You may also like to assign a key to this command:
#
#     Set-PSReadLineKeyHandler -Chord Ctrl+o -ScriptBlock {
#         [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
#         [Microsoft.PowerShell.PSConsoleReadLine]::Insert('a lf')
#         [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
#     }
#
# You may put this in one of the profiles found in $PROFILE.
#

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $lfExe,
    # remaining parameters
    [Parameter(mandatory = $false, DontShow, ValueFromRemainingArguments = $true)]$Remaining
)
. $PSScriptRoot/_lib/Invoke-Directory.ps1
Invoke-Directory {
    param (
        $pathAtCursor, $inputLine, $cursorLeft, $cursorRight
    )

    # $tmp = [System.IO.Path]::GetTempFileName() # a new temp file name inside the temp dir
    try {
        # lf -last-dir-path="$tmp" $args
        $isPath = Test-Path -PathType Container "$pathAtCursor"

        if ($isPath -and ("$pwd" -ne "$pathAtCursor")) {
            $dir = & $lfExe -print-last-dir $pathAtCursor # -last-dir-path=`"$tmp`"
            # note: bug: it will not save the write value into the file
        }
        else {
            $dir = & $lfExe -print-last-dir
            # & $lfExe -last-dir-path="$tmp" @Remaining
        }
        # if (!(Test-Path -PathType Leaf "$tmp")) {
        #     write-host "no path: $tmp"
        #     return
        # }
        #$dir = Get-Content "$tmp"

        return $dir
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)"
        return;
    }
    finally {
        if (!$(Test-Path -PathType Container "$dir")) {
            write-host "$lfExe -print-last-dir $pathAtCursor"
        }
        #Remove-Item -Force "$tmp"
    }
}
