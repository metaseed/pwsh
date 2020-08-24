# include this file in $profile:
# notepad $profile.CurrentUserAllHost
# . m:\script\pwsh\profile.ps1
$ver = $Host.Version;
write-host "v$ver; profile: $PSCommandPath"
. $PSScriptRoot\alias.ps1
$env:path += ";$PSScriptRoot"
Set-PSReadlineKeyHandler -Chord Alt+F4 -Function ViExit

function sudo {
    Start-Process -Verb RunAs -FilePath "pwsh" -ArgumentList (@("-NoExit", "-Command") + $args)
}

function mcd {
    [CmdletBinding()]
    param(
       [Parameter(Mandatory = $true)]
       $Path
    )
 
    # mkdir path
    New-Item -Path $Path -ItemType Directory
    # cd path
    Set-Location -Path $Path
 }