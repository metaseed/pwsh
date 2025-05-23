# for auto update
[CmdletBinding()]
param (
    [Parameter()]
    [int]
    [ValidateRange(0, [int]::MaxValue)]
    $Days = 0
)
Import-Module Metaseed.Lib -DisableNameChecking

if (Test-Update $Days $MyInvocation.MyCommand.Path) {
    # @(1, 20) -contains (Get-Date).day # problem: always update on that day
    [void](
        Start-ThreadJob -StreamingHost $host -ArgumentList $PSScriptRoot {
            param($scriptRoot)
            Write-Verbose "Updating help via a background job" -ForegroundColor yellow
            $back = $ProgressPreference
            # hide progress bar
            $ProgressPreference = 'SilentlyContinue'
            Update-Help -Recurse
            $ProgressPreference = $back
            . $scriptRoot\Lib\update-modules.ps1
        }
    )
}

[void](Start-ThreadJob -StreamingHost $host -ArgumentList "$PSScriptRoot\info.json", $Days {
    param ($localInfo, $days)
    Import-Module Metaseed.Lib -DisableNameChecking
    Update-Installation $localInfo 'https://raw.githubusercontent.com/metasong/pwsh/master/info.json' 'https://pwsh.page.link/0' -days $days
})
