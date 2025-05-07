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

<#
in `lfrc`, pre-quite and pre-quite-select
Q: selects
q: for dir
#>
[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $lfExe,
    # remaining parameters
    [Parameter(mandatory = $false, DontShow, ValueFromRemainingArguments = $true)]$Remaining
)

if ( $Remaining -contains '-remote') {
    Show-MessageBox "$($Remaining -join ','), please use 'c:\app\lf.exe -remote to send command"
    #i.e. c:\app\lf.exe -remote "send $env:id push :rename<space>$name"
    return
}

$chordTrigger = $Remaining -contains '-ChordTrigger'
if ($chordTrigger) {
    $null = $remaining.remove('-ChordTrigger')
}

$PassThru = $Remaining -contains '-PassThru'
if ($PassThru) {
    $null = $remaining.remove('-PassThru')
}
# Show-MessageBox "pass: $passThru"
# $isSelections = $Remaining -contains '-selections'
# if($isSelections) {
#   $remaining.remove('-selections')
# }
# $isDir = $Remaining -contains '-dir'
# if($isDir) {
#   $remaining.remove('-dir')
# }

. $PSScriptRoot/_lib/Invoke-OnPsLine.ps1

Invoke-OnPsLine -isChordTrigger:$chordTrigger -PassThru:$PassThru { # -isSelections:$isSelections -isDir:$isDir
    [CmdletBinding()]
    param (
        $pathAtCursor, $inputLine, $cursorLeft, $cursorRight
    )

    # $tmp = [IO.Path]::GetTempFileName() # a new temp file name inside the temp dir
    try {
        # only output path when invoke from chord (alt+e)
        if ($chordTrigger) {
            if (Test-path $pathAtCursor) {
                $pathAtCursor = resolve-path $pathAtCursor # resolve-path to convert m: to m:\, lf.exe do not accept m: directly(it will become pwd\m:)
                # $isFolder = Test-Path -PathType Container $pathAtCursor
                # lf -last-dir-path="$tmp" $args
                # if($isFolder -and ($pwd -ne $pathAtCursor)){
                #     Write-Host "$lfExe -print-last-dir $pathAtCursor $Remaining"
                $dir = & $lfExe -print-last-dir $pathAtCursor @Remaining
                #     # note: bug:  -last-dir-path=`"$tmp`" it will not save the write value into the file when the current dir is different with the path at cursor
                # }

            }
            else {
                # empty or not a pathi
            }
        }
        else {
            # Write-Host "aaa"+ $Remaining
            $dir = & $lfExe -print-last-dir @Remaining
            # & $lfExe -last-dir-path="$tmp" @Remaining
        }

        # if (!(Test-Path -PathType Leaf "$tmp")) {
        #     write-host "no path: $tmp"
        #     return
        # }
        #$dir = Get-Content "$tmp"

        # not use $dir now, but to use json file
        # {
        #     "workingDir": "C:\\Windows\\System32",
        #     "lastSelections": [
        #       "C:\\Windows\\System32\\0409",
        #       "C:\\Windows\\System32\\1028"
        #     ]
        # }

        # saved from lfcf on-quit event
        $onQuit = gc $env:temp\lf-onQuit.json | ConvertFrom-Json

        # $onQuit = @{workingDir = $dir}

        return $onQuit
    }
    catch {
        Write-ErrorDetails $_
        # Write-Host "Error: $($_.Exception)"
        return;
    }
    finally {
        if (!$(Test-Path -PathType Container "$dir")) {
            write-host "$lfExe -print-last-dir $pathAtCursor"
        }
        #Remove-Item -Force "$tmp"
    }
}

<#
lf -o|sl
ctrl+s
ctrl+d
sl ctrl+d
#>

