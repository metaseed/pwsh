<#
.SYNOPSIS
 open web
#>
[CmdletBinding()]
param (
  [ArgumentCompleter( {
      param ( 
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters )
      . $psscriptroot\_config.ps1

      $appsKeys = $apps.keys
      $app = $appsKeys | ? {
        $_ -like "*${wordToComplete}*"
      }
      if ($app) {
        return $app
      }

      $word = ($wordToComplete -split '' -join '*')
      return $appsKeys | ? {
        $_ -like "${word}"
      }
    })]
  [Parameter(Position = 0)]
  [string]$web,
  
  [Parameter()]
  [Hashtable]
  $webs,

  # browser profile to use
  [Parameter()]
  [string]
  $prof = "Profile 1",

  # list available names
  [Parameter()]
  [switch]
  $list
)
. "$PSScriptRoot\_config.ps1"
if($webs) {
  $webs|%{$apps.$($_.key)= $_.value}
}
if($list) {
  write-host "`nAvailable Names:"
  $apps|Format-Table
  return
}

# note: directly use $Verbose not work
if($PsBoundParameters.Verbose) {
 $apps|format-table
}
Write-Verbose $apps.$web
saps msedge -ArgumentList @("--profile-directory=`"$prof`"", $apps.$web)

# note: it's linked
# ni -Type HardLink M:\Work\Slb-Presto\drilldev\command\Web\