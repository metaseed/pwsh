<#
.SYNOPSIS
Retrieves process information that has a file handle open to the specified path.
.LINK
We extract the output from the handle.exe utility from SysInternals:
https://docs.microsoft.com/en-us/sysinternals/downloads/handle

.Example
Find-LockingProcess -Path $Env:LOCALAPPDATA

.Example
 Find-LockingProcess -Path $Env:LOCALAPPDATA | Get-Process
#>
function Find-LockingProcess {
    [OutputType([array])]
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [object] $Path
    )
    $HandleDir = "$env:MS_App\handle"
    $HandleApp = "$HandleDir\handle.exe"
    if (!(Test-Path -Path $HandleApp)) {
        # Add-PathEnv $HandleDir
        DownloadHandleApp -Path $HandleDir
    }
    $AppInfo = Get-Command $HandleApp -ErrorAction Stop
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

    if (!(test-path $path)) {
        Write-Error "Path $path does not exist"
        return
    }

    $HandleDir = "$env:MS_App\handle"
    $HandleApp = "$HandleDir\handle.exe"

    #Initialize-SystemInternalsApp -AppRegName "Handle"
    $PathName = (Resolve-Path -Path $Path).Path.TrimEnd("\") # Ensures proper .. expansion & slashe \/ type
    #   -u         Show the owning user name when searching for handles.
    $LineS = & $AppInfo.Path -accepteula -u $PathName -nobanner


    foreach ($Line in $LineS) {
        write-verbose $Line
        # new version(20260219) of handle.exe has a new format:
        # explorer.exe       pid: 16652  type: File          DIR\JSong12               5ad808X M:\Workspace\metatool\src\app\LeaveScr\obj
        # old version of handle.exe has a format with a ':' after the handle number:
        # "pwsh.exe           pid: 5808   type: File          Domain\UserName             48: D:\MySuff\Modules"
        if ($Line -match "(?<proc>.+)\s+pid: (?<pid>\d+)\s+type: (?<type>\w+)\s+(?<user>.+)\s+(?<hnum>\w+)\:?\s+(?<path>.*)\s*") {
            $Proc = $Matches.proc.Trim()
            if (@("handle.exe", "Handle64.exe") -notcontains $Proc) {
                $Retval = [PSCustomObject]@{
                    Pid     = $Matches.pid
                    Process = $Proc
                    User    = $Matches.user.Trim()
                    Handle  = $Matches.hnum
                    Path    = $Matches.path
                }
                Write-Output $Retval
            }
        } else {
            write-verbose "can not extract info from line: $Line"
        }
    }
}


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

# Find-LockingProcess -Path "M:\Workspace\metatool\src\app\LeaveScr\obj"