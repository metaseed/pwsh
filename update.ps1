# for auto update
[CmdletBinding()]
param (
    [Parameter()]
    [int]
    [ValidateRange(0, [int]::MaxValue)]
    $Days = 0
)
Import-Module Metaseed.Lib -DisableNameChecking

if (Test-Update 20 $MyInvocation.MyCommand.Path) { # @(1, 20) -contains (Get-Date).day # problem: always update on that day
    [void](
        Start-ThreadJob -StreamingHost $host {
            Write-Host "Updating help via a background job" -ForegroundColor yellow
            Update-Help -force

            'PSReadline', 'PowershellGet', 'Pester', 'Microsoft.PowerShell.ConsoleGuiTools' | % {
                $module = $_
                # write-host "try update module $module" -ForegroundColor Yellow
                $error.Clear()
                Update-Module $module -ErrorAction SilentlyContinue
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

[void](Start-ThreadJob -StreamingHost $host {
        Import-Module Metaseed.Lib -DisableNameChecking
        Update-Installation $localInfo 'https://raw.githubusercontent.com/metasong/pwsh/master/info.json' 'https://pwsh.page.link/0' -days $Days
    })
