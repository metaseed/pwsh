# note: auto-setup in config.ps1

# include this file in $profile:
# notepad $profile.CurrentUserAllHost
# . m:\script\pwsh\profile.ps1

# note: reload profile if modified codes in this repo
# & $profile.CurrentUserAllHosts
Clear-Host
$IsAdmin = ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")
"`e[5mpwsh`e[0m v$($Host.Version) `e[33;3;4m$($IsAdmin ? 'admin':'')`e[0m" #; profile: $PSCommandPath"

# not needed if we run pwsh with -noexit, so even we install ms_pwsh from v5 powershell, we still in pwsh.
# fix after install, the env is not updated
# if(-not $env:MS_PWSH) {
#   $env:MS_PWSH = [System.Environment]::GetEnvironmentVariable("MS_PWSH", "User")
# }

# $InformationPreference = 'Continue' # SilentlyContinue (default); to display Write-Information message
. $PSScriptRoot\profile\main.ps1
. $PSScriptRoot\update.ps1 -days 3