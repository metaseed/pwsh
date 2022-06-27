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

      . $env:MS_PWSH\Lib\WebConfigMatch.ps1
    })]
  [Parameter(Position = 0)]
  [string]$web,
  
  [Parameter()]
  [Hashtable]
  $urls,

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
if ($urls) {
  $webs | % { $webs.$($_.key) = $_.value }
}
if ($list) {
  write-host "`nAvailable Names:"
  $webs | Format-Table
  return
}

# note: directly use $Verbose not work
if ($PsBoundParameters.Verbose) {
  $webs | format-table
}
if ($webs[$web]) { Write-Verbose $webs[$web] }
saps msedge -ArgumentList @("--profile-directory=`"$prof`"", $webs[$web])

# note: it's linked
# ni -Type HardLink M:\Work\Slb-Presto\drilldev\command\Web\Web.ps1 -Value M:\Script\Pwsh\Cmdlet\s\Command\Web\Web.ps1