# note: auto-setup in config.ps1

# include this file in $profile:
# notepad $profile.CurrentUserAllHost
# . m:\script\pwsh\profile.ps1

# note: reload profile if modified codes in this repo
# & $profile.CurrentUserAllHosts
Clear-Host
"v$($Host.Version); profile: $PSCommandPath"
$InformationPreference = 'Continue' # SilentlyContinue (default); to display Write-Information message
. $PSScriptRoot\profile\main.ps1
. $PSScriptRoot\up.ps1 1
