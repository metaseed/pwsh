
function Write-AllSubCommands {
  param([string]$commandFolder)
  Write-Host "You could run these sub-commands:`n"

  Write-FileTree $commandFolder  @('^[^_]', '\.ps1$')  @('^[^_]') 

  $p = Split-Path $commandFolder
  $cmd = Split-Path $p -Leaf
  $c = gci $p -Filter "*.cmd"
  if ($c) {
    $cmd = $c[0].BaseName
  }
  Write-Host "`nto get help: $cmd <subcommand> -h"
}
# Write-AllSubCommands 'M:\Work\SLB\Presto\drilldev'