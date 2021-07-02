# include this file in $profile:
# notepad $profile.CurrentUserAllHost
# . m:\script\pwsh\profile.ps1
Clear-Host
"v$($Host.Version); profile: $PSCommandPath"
$InformationPreference = 'Continue' # SilentlyContinue (default); whether to display Write-Information message
. $PSScriptRoot\config\var.ps1
. $PSScriptRoot\Lib\env.ps1
. $PSScriptRoot\Lib\alias.ps1
. $PSScriptRoot\Lib\PSReadlineConfig.ps1
. $PSScriptRoot\Lib\utilities.ps1
. $PSScriptRoot\Lib\BeepMusic.ps1
. $PSScriptRoot\presto\main.ps1
. $PSScriptRoot\upgrade.ps1
