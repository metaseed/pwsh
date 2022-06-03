<#
.SYNOPSIS
Kills all processes that have a file handle open to the specified path.

.Example
Stop-LockingProcess -Path $Home\Documents 
#>
function Stop-LockingProcess {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [object] $Path
    )

    Write-Host "find process that use the $Path, `n stop them..."
    $ProcS = Find-LockingProcess -Path $Path | Sort-Object -Property Pid -Unique
    $ProcS
    Kill-Process -ProcessId $ProcS.Pid
}

