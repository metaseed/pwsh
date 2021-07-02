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
    $infoRemote = iwr $RemoteInfoUrl -TimeoutSec 5 | ConvertFrom-Json
    return $infoRemote.version -ne $infoLocal.version  
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
    if (Test-Installation $LocalInfoPath $RemoteInfoUrl) {

        write-host "> New version($remoteVersion), press Enter to upgrade, other key to continue"

        $key = [System.Console]::ReadKey().Key
        if ($key -eq [ConsoleKey]::Enter) {
            iwr $InstallUrl | iex
        }
    }
}
