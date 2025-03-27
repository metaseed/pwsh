# note: auto-setup in config.ps1

# include this file in $profile:
# notepad $profile.CurrentUserAllHost
# . m:\script\pwsh\profile.ps1

# note: reload profile if modified codes in this repo
# & $profile.CurrentUserAllHosts
# by default it's Chinese Simplified (GB2312), is it because i installed Chinese simplified in the windows system?
# so let change it to UTF8 explicitly
[Console]::OutputEncoding = [Text.Encoding]::UTF8

# Clear-Host # it will delete all pervious logs
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
"`e[5mpwsh`e[0m v$($Host.Version) `e[33;3;4m$($IsAdmin ? 'admin':'')`e[0m" #; profile: $PSCommandPath"

# not needed if we run pwsh with -noexit, so even we install ms_pwsh from v5 powershell, we still in pwsh.
# fix after install, the env is not updated
# if(-not $env:MS_PWSH) {
#   $env:MS_PWSH = [System.Environment]::GetEnvironmentVariable("MS_PWSH", "User")
# }

# $InformationPreference = 'Continue' # SilentlyContinue (default); to display Write-Information message
. $PSScriptRoot\profile\main.ps1
. $PSScriptRoot\update.ps1 -days 3