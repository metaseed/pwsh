function Test-Installation {
    [CmdletBinding()]
    param (
        # local info.json path
        [string]
        $LocalInfoPath,
        # remote info.json url
        [string]
        $RemoteInfoUrl,
        [switch]
        $Confirm
    )

    $infoLocal = Get-Content $LocalInfoPath | ConvertFrom-Json
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $infoRemote = iwr $RemoteInfoUrl -TimeoutSec 10 | ConvertFrom-Json
    $rv = New-Object Version($infoRemote.version)
    $lv = New-Object Version($infoLocal.version)
    return $rv -gt $lv ? $infoLocal.version : $false
}

function Test-Update([int]$days, [string]$file) {
    if ($days -gt 0) {
        $_days = ((Get-Date) - (gi $file).LastWriteTime).Days
        if ($_days -lt $days) {
            return $false
        }
        # update last write time so we do update $day later
        (gi $file).LastWriteTime = Get-Date
    }
    return $true
}

function Update-Installation {
    param (
        # local info.json path
        [string]
        [Parameter(Mandatory = $true)]
        $LocalInfoPath,
        # remote info.json url
        [string]
        $RemoteInfoUrl,
        # install.ps1 path
        [string]
        $InstallUrl,
        [int]$days = 0,
        [switch]
        $Confirm
    )
    # .local file only exist local and igored in .gitignore file; used to prevent upgrade
    $localFolder = Split-Path $localInfoPath
    $localFile = "$localFolder/.git"
    if (Test-Update $days $localFile) {
        return
    }

    $update = Test-Update $days $LocalInfoPath
    if (!$update) { return }

    $ver = Test-Installation $LocalInfoPath $RemoteInfoUrl
    if ($ver) {
        if ($Confirm) {
            write-host -f Yellow "> New version($ver) found at $InstallUrl,`n press Enter to upgrade, other key to cancel and continue"
            $key = [Console]::ReadKey().Key
            if ($key -ne [ConsoleKey]::Enter) {
                return
            }
        }
        write-host -f Green "> Upgrading ($ver) from '$RemoteInfoUrl'..."
        # -UseBasicParsing for pwsh 5
        iwr -UseBasicParsing $InstallUrl | iex
    }
}

Export-ModuleMember Test-Update

