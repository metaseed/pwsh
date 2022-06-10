
[CmdletBinding()]
param (
    [Parameter()]
    [int]
    [ValidateRange(0, [int]::MaxValue)]
    $Days = 0
)
Import-Module Metaseed.Lib -DisableNameChecking

$localInfo = "$PSScriptRoot\info.json"
Update-Installation $localInfo 'https://raw.githubusercontent.com/metasong/pwsh/master/info.json' 'https://pwsh.page.link/0' -days $Days

