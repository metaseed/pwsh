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
    # if in a git foler, we are developers, pull the latest code
    $localFolder = Split-Path $localInfoPath

    $update = Test-Update $days $LocalInfoPath
    if (!$update) { return }

    $localFile = "$localFolder/.git"
    if (Test-Path $localFile) {
        push-location $localFolder
        git pull --rebase
        if(!$?) {write-warning "error when pull latest code to $localFolder, do you have changes to merge?"}
        Pop-Location
        return
    }

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

