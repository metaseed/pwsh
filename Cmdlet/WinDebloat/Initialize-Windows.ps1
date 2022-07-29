[CmdletBinding()]
param (
  [Parameter()]
  [bool]
  $vm
)

. $PSScriptRoot\..\_lib\Utils.ps1

& $PSScriptRoot\_lib\Config-Apps.ps1 $vm
& $PSScriptRoot\_lib\Config-Services.ps1 $vm
& $PSScriptRoot\_lib\Config-Shell.ps1 $vm
& $PSScriptRoot\_lib\Config-TaskScheduler.ps1 $vm
& $PSScriptRoot\_lib\Config-System.ps1 $vm

