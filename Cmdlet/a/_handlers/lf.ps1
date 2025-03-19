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
    [Parameter(mandatory = $false,  DontShow, ValueFromRemainingArguments = $true)]$Remaining
)

$tmp = [System.IO.Path]::GetTempFileName() # a new temp file name inside the temp dir
# lf -last-dir-path="$tmp" $args

& $lfExe -last-dir-path="$tmp" @Remaining
# returned from lf UI
if (Test-Path -PathType Leaf "$tmp") {
    $dir = Get-Content "$tmp"
    Remove-Item -Force "$tmp"
    if (Test-Path -PathType Container "$dir") {
        if ("$dir" -ne "$pwd") {
            cd "$dir"
        }else {
            #return [Microsoft.PowerShell.PSConsoleReadLine]::Insert($dir)
        }
    }

}