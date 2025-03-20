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

$leftCursor = $null
$rightCursor = $null
$line = $null
$cursor = $null
[Microsoft.PowerShell.PSConsoleReadline]::GetBufferState([ref]$line, [ref]$cursor)
$currentPath = Find-PsReadlinePath $line $cursor ([ref]$leftCursor) ([ref]$rightCursor)

$tmp = [System.IO.Path]::GetTempFileName() # a new temp file name inside the temp dir
$isPath = $false

try {
    # lf -last-dir-path="$tmp" $args
    if(Test-Path -PathType Container $currentPath){
        $isPath = $true
    }

    if ($isPath -and ("$pwd" -ne "$currentPath")) {
        & $lfExe "$currentPath -last-dir-path=$tmp" @Remaining
    }
    else {
        & $lfExe -last-dir-path="$tmp" @Remaining
    }
    # if (!(Test-Path -PathType Leaf "$tmp")) {
    #     write-host "no path: $tmp"
    #     return
    # }
    $dir = Get-Content "$tmp"
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
    return;
}
finally {
    Remove-Item -Force "$tmp"
}
##
## returned from lf UI
##
if (!(Test-Path -PathType Container "$dir")) {
    write-host " & $lfExe '$currentPath' -last-dir-path='$tmp' @Remaining"
    write-host "the returned path is not a dir: $dir tmp:$tmp,exist:$(Test-Path $tmp); currentPath:$currentPath,isPath:$isPath, line:$line,cursorLeft:$leftCursor,rightCursor:$rightCursor. lf.exe:$lfExe"
    return
}

if (("$dir" -ne "$pwd") -and [string]::IsNullOrWhiteSpace($line)) {
    sl "$dir"
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
else {
    if ($isPath) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($leftCursor, $rightCursor - $leftCursor + 1, $dir)
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($dir)
    }
    #return [Microsoft.PowerShell.PSConsoleReadLine]::Insert($dir)
}
