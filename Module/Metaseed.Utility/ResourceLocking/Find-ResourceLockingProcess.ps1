<#
.SYNOPSIS
  Utility to discover/kill processes that have open handles to a file or folder.

  Find-ResourceLockingProcess()
    Retrieves process information that has a file handle open to the specified path.
    Example: Find-ResourceLockingProcess -Path $Env:LOCALAPPDATA
    Example: Find-ResourceLockingProcess -Path $Env:LOCALAPPDATA | Get-Process

  Stop-LockingProcess()
    Kills all processes that have a file handle open to the specified path.
    Example: Stop-LockingProcess -Path $Home\Documents 
#>



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
Retrieves process information that has a file handle open to the specified path.
.LINK 
We extract the output from the handle.exe utility from SysInternals:
https://docs.microsoft.com/en-us/sysinternals/downloads/handle

.Example 
Find-ResourceLockingProcess -Path $Env:LOCALAPPDATA

.Example
 Find-ResourceLockingProcess -Path $Env:LOCALAPPDATA | Get-Process
#>
function Find-ResourceLockingProcess {
    [OutputType([array])]
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [object] $Path
    )

    $AppInfo = Get-Command $Script:HandleApp -ErrorAction Stop
    if ($AppInfo) {
        findLocking $Path $AppInfo | sort -Unique -Property Pid, User, Path
    }
}

function findLocking {
    param (
        [Parameter(Position = 0)]
        [object] $Path,
        [Parameter(Position = 1)]
        [object]$AppInfo
    )
    #Initialize-SystemInternalsApp -AppRegName "Handle"
    $PathName = (Resolve-Path -Path $Path).Path.TrimEnd("\") # Ensures proper .. expansion & slashe \/ type
    #   -u         Show the owning user name when searching for handles.
    $LineS = & $AppInfo.Path -accepteula -u $PathName -nobanner
    # $LineS
    foreach ($Line in $LineS) {
        # "pwsh.exe           pid: 5808   type: File          Domain\UserName             48: D:\MySuff\Modules"
        if ($Line -match "(?<proc>.+)\s+pid: (?<pid>\d+)\s+type: (?<type>\w+)\s+(?<user>.+)\s+(?<hnum>\w+)\:\s+(?<path>.*)\s*") {
            $Proc = $Matches.proc.Trim()
            if (@("handle.exe", "Handle64.exe") -notcontains $Proc) {
                $Retval = [PSCustomObject]@{
                    Pid     = $Matches.pid
                    Process = $Proc
                    User    = $Matches.user.Trim()
                    # Handle  = $Matches.hnum
                    Path    = $Matches.path
                }
                Write-Output $Retval
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

    $ProcS = Find-ResourceLockingProcess -Path $Path | Sort-Object -Property Pid -Unique
    "find process that use the $Path, `n stop them..."
    $ProcS
    Kill_Process -ProcessId $ProcS.Pid
}

Export-ModuleMember -Function Stop-LockingProcess


#########   Initialize Module   #########
function DownloadHandleApp($Path) {
    $ZipFile = "Handle.zip"
    $ZipFilePath = "$Path\$ZipFile"
    $Uri = "https://download.sysinternals.com/files/$ZipFile"
    try {
        Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
        $null = New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop
        Invoke-RestMethod -Method Get -Uri $Uri -OutFile $ZipFilePath -ErrorAction Stop
        Expand-Archive -Path $ZipFilePath -DestinationPath $Path -Force -ErrorAction Stop
        Remove-Item -Path $ZipFilePath -ErrorAction SilentlyContinue
    }
    catch {
        Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
        Throw "Failed to download dependency: handle.exe from: $Uri"
    }
}

$Script:HandleDir = "$PSScriptRoot\_handle"
$Script:HandleApp = "$HandleDir\handle.exe"
if (!(Test-Path -Path $Script:HandleApp)) {
    Add-Path $Script:HandleDir
    DownloadHandleApp -Path $HandleDir
}
