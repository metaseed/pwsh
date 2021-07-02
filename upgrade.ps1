using module Metaseed.Utility

$localInfo = "$PSScriptRoot\info.json"
$days = ((Get-Date) - (gi $localInfo).LastWriteTime).Days
if($days -gt 7) {
    (gi $localInfo).LastWriteTime = Get-Date
    Update-Installation $localInfo 'https://raw.githubusercontent.com/metasong/pwsh/master/info.json' 'https://pwsh.page.link/0'
}
