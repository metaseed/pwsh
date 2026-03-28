# for auto update — fully deferred to background to avoid blocking profile load (~107ms saved)
[CmdletBinding()]
param (
    [Parameter()]
    [int]
    [ValidateRange(0, [int]::MaxValue)]
    $Days = 0
)

[void](Start-ThreadJob -StreamingHost $host -ArgumentList $PSScriptRoot, "$PSScriptRoot\info.json", $Days, $MyInvocation.MyCommand.Path {
    param($scriptRoot, $localInfo, $days, $scriptPath)
    Import-Module Metaseed.Lib -DisableNameChecking

    if (Test-Update $days $scriptPath) {
        # @(1, 20) -contains (Get-Date).day # problem: always update on that day
        Write-Verbose "Updating help via a background job" -ForegroundColor yellow
        $back = $ProgressPreference
        # hide progress bar
        $ProgressPreference = 'SilentlyContinue'
        Update-Help -Recurse
        $ProgressPreference = $back
        . $scriptRoot\Lib\update-modules.ps1
    }

    Update-Installation $localInfo 'https://raw.githubusercontent.com/metasong/pwsh/master/info.json' 'https://pwsh.page.link/0' -days $days
})
