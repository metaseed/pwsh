# for auto update — inline Test-Update check to skip ThreadJob when not due
[CmdletBinding()]
param (
    [Parameter()]
    [int]
    [ValidateRange(0, [int]::MaxValue)]
    $Days = 0
)

# inline Test-Update: skip if file was written less than $Days ago
if ($Days -gt 0 -and ((Get-Date) - (Get-Item $MyInvocation.MyCommand.Path).LastWriteTime).Days -lt $Days) { return }

[void](Start-ThreadJob -StreamingHost $host -ArgumentList $PSScriptRoot, "$PSScriptRoot\info.json", $Days, $MyInvocation.MyCommand.Path {
    param($scriptRoot, $localInfo, $days, $scriptPath)
    Import-Module Metaseed.Lib -DisableNameChecking

    # stamp file so next profile load skips the ThreadJob
    (Get-Item $scriptPath).LastWriteTime = Get-Date

    Write-Verbose "Updating help via a background job" -ForegroundColor yellow
    $back = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    Update-Help -Recurse
    $ProgressPreference = $back
    . $scriptRoot\Lib\update-modules.ps1

    Update-Installation $localInfo 'https://raw.githubusercontent.com/metasong/pwsh/master/info.json' 'https://pwsh.page.link/0' -days $days
})
