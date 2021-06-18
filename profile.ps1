# include this file in $profile:
# notepad $profile.CurrentUserAllHost
# . m:\script\pwsh\profile.ps1
Clear-Host
"v$($Host.Version); profile: $PSCommandPath"
$InformationPreference = 'Continue' # SilentlyContinue (default); whether to display Write-Information message
$env:MyDoc = [Environment]::GetFolderPath('MyDocument');
$env:PSModulePath += ";$PSScriptRoot\Modules"
$env:path += ";$PSScriptRoot\Cmdlet"
$Private:appFolder = 'C:\App'
if (Test-Path $Private:appFolder) {
    #note: app folder has already been add to path when do mapping
    $env:path += ";" + ((Get-ChildItem -Attributes Directory -Path $Private:appFolder -Name | ForEach-Object { join-path $Private:appFolder $_ }) -join ';')
}
. $PSScriptRoot\Lib\alias.ps1
. $PSScriptRoot\Lib\PSReadlineConfig.ps1
. $PSScriptRoot\Lib\utilities.ps1
. $PSScriptRoot\Lib\BeepMusic.ps1
. $PSScriptRoot\presto\presto.ps1