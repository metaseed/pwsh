# include this file in $profile:
# notepad $profile.CurrentUserAllHost
# . m:\script\pwsh\profile.ps1
Clear-Host
"v$($Host.Version); profile: $PSCommandPath"
$InformationPreference = 'Continue' # SilentlyContinue (default); whether to display Write-Information message
. $PSScriptRoot\lib\main.ps1
. $PSScriptRoot\presto\main.ps1
. $PSScriptRoot\up.ps1 1