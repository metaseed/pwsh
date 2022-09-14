# for auto update
[CmdletBinding()]
param (
    [Parameter()]
    [int]
    [ValidateRange(0, [int]::MaxValue)]
    $Days = 0
)
Import-Module Metaseed.Lib -DisableNameChecking

if (@(1, 20) -contains (Get-Date).day) {
    [void](
        Start-ThreadJob -StreamingHost $host {
            Write-Host "Updating help via a background job" -ForegroundColor yellow
            Update-Help -force

            'PSReadline', 'PowershellGet', 'Pester', 'Microsoft.PowerShell.ConsoleGuiTools' | % {
                $module = $_
                # write-host "try update module $module" -ForegroundColor Yellow
                $error.Clear()
                Update-Module $module
                if ($error) {
                    Install-Module $module -force
                }
            }

            $options = Get-PSReadLineOption
            $options.ListPredictionColor = "`e[90m" # original value "`e[33m"
        }
    )
}

$localInfo = "$PSScriptRoot\info.json"

$update = Test-Update $Days $localInfo
if (!$update) { return }

[void](Start-ThreadJob -StreamingHost $host {
        Import-Module Metaseed.Lib -DisableNameChecking
        Update-Installation $localInfo 'https://raw.githubusercontent.com/metasong/pwsh/master/info.json' 'https://pwsh.page.link/0' -days $Days
    })
