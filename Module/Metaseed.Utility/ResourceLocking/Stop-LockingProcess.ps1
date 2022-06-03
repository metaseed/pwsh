<#
.SYNOPSIS
Helper function to stop one or more processes with extra error handling and logging.
We first try stop the process nicely by calling Stop-Process().
But if the process is still running after the timeout expires then we
do a hard kill.
#>
function Kill_Process {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [int[]] $ProcessId,

        [parameter()]
        [int] $TimeoutSec = 2
    )

    begin {
        [int[]] $ProcIdS = @()
    }
    process {
        if ($ProcessId) {
            $ProcIdS += $ProcessId
        }
    }
    end {
        if ($ProcIdS) {
            [array]$CimProcS = $null
            [array]$StoppedIdS = $null
            foreach ($ProcId in $ProcIdS) {
                $CimProc = Get-CimInstance -Class Win32_Process -Filter "ProcessId = '$ProcId'" -Verbose:$false
                $CimProcS += $CimProc
                if ($CimProc) {
                    Write-Verbose "Stopping process: $($CimProc.Name)($($CimProc.ProcessId)), ParentProcessId:'$($CimProc.ParentProcessId)', Path:'$($CimProc.Path)'"
                    Stop-Process -Id $CimProc.ProcessId -Force -ErrorAction Ignore
                    $StoppedIdS += $CimProc.ProcessId
                }
                else {
                    Write-Verbose "Process($ProcId) already stopped"
                }
            }

            if ($StoppedIdS) {
                if ($TimeoutSec) {
                    Write-Verbose "Waiting for processes to stop TimeoutSec: $TimeoutSec"
                    Wait-Process -Id $StoppedIdS -Timeout $TimeoutSec -ErrorAction ignore
                }

                # Verify that none of the stopped processes exist anymore
                [array] $NotStopped = $null
                foreach ($ProcessId in $StoppedIdS) {
                    # Hard kill the proess if the gracefull stop failed
                    $Proc = Get-Process -Id $ProcessId -ErrorAction Ignore
                    if ($Proc -and !$Proc.HasExited) {
                        $ProcInfo = "Process: $($Proc.Name)($ProcessId)"
                        Write-Verbose "Killing process because of timeout waiting for it to stop, $ProcInfo" -Verbose
                        try {
                            $Proc.Kill()
                        }
                        catch {
                            Write-Warning "Kill Child-Process Exception: $($_.Exception.Message)"
                        }
                        Wait-Process -Id $ProcessId -Timeout 2 -ErrorAction ignore

                        $CimProc = Get-CimInstance -Class Win32_Process -Filter "ProcessId = '$ProcessId'" -Verbose:$false
                        if ($CimProc) {
                            $NotStopped += $CimProc
                        }
                    }
                }

                if ($NotStopped) {
                    $ProcInfoS = ($NotStopped | ForEach-Object { "$($_.Name)($($_.ProcessId))" }) -join ", "
                    $ErrMsg = "Timeout-Error stopping processes: $ProcInfoS"
                    if (@("SilentlyContinue", "Ignore", "Continue") -notcontains $ErrorActionPreference) {
                        Throw $ErrMsg
                    }
                    Write-Warning $ErrMsg
                }
                else {
                    $ProcInfoS = ($CimProcS | ForEach-Object { "$($_.Name)($($_.ProcessId))" }) -join ", "
                    Write-Output "Finished stopping processes: $ProcInfoS"
                }
            }
        }
    }
}

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
    Kill_Process -ProcessId $ProcS.Pid
}

