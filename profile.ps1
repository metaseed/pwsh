# include this file in $profile:
# notepad $profile.CurrentUserAllHost
# . m:\script\pwsh\profile.ps1
$ver = $Host.Version;
write-host "v$ver; profile: $PSCommandPath"
. $PSScriptRoot\alias.ps1
. $PSScriptRoot\presto\presto.ps1
$env:path += ";$PSScriptRoot"
Set-PSReadlineKeyHandler -Chord Alt+F4 -Function ViExit
. $PSScriptRoot\utilities.ps1