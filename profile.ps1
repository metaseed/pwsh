# include this file in $profile:
# notepad $profile.CurrentUserAllHost
# . m:\script\pwsh\profile.ps1
Clear-Host
write-host "v$($Host.Version); profile: $PSCommandPath"
$InformationPreference = 'Continue' # SilentlyContinue (default); whether to display Write-Information message
$myDoc = [Environment]::GetFolderPath('MyDocument');
$env:PSModulePath += ";$PSScriptRoot\Modules"
$env:path += ";$PSScriptRoot"
$env:path += ";" + ((get-childitem -attributes directory -path c:\App -name | ForEach-Object { join-path "c:\App\" $_ }) -join ';')
Set-PSReadlineKeyHandler -Chord Alt+F4 -Function ViExit
. $PSScriptRoot\alias.ps1
. $PSScriptRoot\presto\presto.ps1
. $PSScriptRoot\utilities.ps1