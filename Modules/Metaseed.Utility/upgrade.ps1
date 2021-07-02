function Test-Installation {
    [CmdletBinding()]
    param (
        # local info.json path
        [string]
        $LocalInfoPath,
        # remote info.json url
        [string]
        $RemoteInfoUrl
    )
    
    $infoLocal = Get-Content $LocalInfoPath | ConvertFrom-Json
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $infoRemote = iwr $RemoteInfoUrl -TimeoutSec 10 | ConvertFrom-Json
    return $infoRemote.version -ne $infoLocal.version ? $infoLocal.version : $false
}
function Update-Installation {
    param (
        # local info.json path
        [string]
        $LocalInfoPath,
        # remote info.json url
        [string]
        $RemoteInfoUrl,
        # install.ps1 path
        [string]
        $InstallUrl
    )
    $ver = Test-Installation $LocalInfoPath $RemoteInfoUrl
    if ($ver) {

        write-host "> New version($ver), press Enter to upgrade, other key to continue"

        $key = [System.Console]::ReadKey().Key
        if ($key -eq [ConsoleKey]::Enter) {
            iwr $InstallUrl | iex
        }
    }
}
