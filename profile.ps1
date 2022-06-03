# note: auto-setup in config.ps1

# include this file in $profile:
# notepad $profile.CurrentUserAllHost
# . m:\script\pwsh\profile.ps1

# note: reload profile if modified codes in this repo
# & $profile.CurrentUserAllHosts
Clear-Host
"pwsh v$($Host.Version)" #; profile: $PSCommandPath"

# not needed if we run pwsh with -noexit, so even we install ms_pwsh from v5 powershell, we still in pwsh.
# fix after install, the env is not updated
# if(-not $env:MS_PWSH) {
#   $env:MS_PWSH = [System.Environment]::GetEnvironmentVariable("MS_PWSH", "User")
# }

$InformationPreference = 'Continue' # SilentlyContinue (default); to display Write-Information message
. $PSScriptRoot\profile\main.ps1
. $PSScriptRoot\up.ps1 1