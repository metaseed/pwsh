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
    $file,
    # remaining parameters
    [Parameter()]
    $remaining
)

$tmp = [System.IO.Path]::GetTempFileName()
# lf -last-dir-path="$tmp" $args

& $file -last-dir-path="$tmp" @Remaining

if (Test-Path -PathType Leaf "$tmp") {
    $dir = Get-Content "$tmp"
    Remove-Item -Force "$tmp"
    if (Test-Path -PathType Container "$dir") {
        if ("$dir" -ne "$pwd") {
            cd "$dir"
        }
    }
}