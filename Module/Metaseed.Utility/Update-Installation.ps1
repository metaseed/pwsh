<#

#>
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
function Update-Installation {
    param (
        # local info.json path
        [string]
        [Parameter(Mandatory=$true)]
        $LocalInfoPath,
        # remote info.json url
        [string]
        $RemoteInfoUrl,
        # install.ps1 path
        [string]
        $InstallUrl,
        [switch]
        $Confirm
    )
    $ver = Test-Installation $LocalInfoPath $RemoteInfoUrl
    if ($ver) {
        if ($Confirm) {
            write-host -f Yellow "> New version($ver), press Enter to upgrade, other key to continue"
            $key = [Console]::ReadKey().Key
            if ($key -ne [ConsoleKey]::Enter) {
                return
            }
        }
        write-host -f Green "> Upgrading from '$RemoteInfoUrl' ($ver)..."
        iwr $InstallUrl | iex
    }
}

