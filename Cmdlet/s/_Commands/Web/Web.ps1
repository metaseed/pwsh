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
  # "$env:LOCALAPPDATA\Google\Chrome\User Data"
  [Parameter()]
  [string]
  $prof = "Profile 1"

)
. "$PSScriptRoot\_config.ps1"
if ($urls) {
  $webs | % { $webs.$($_.key) = $_.value }
}
if (!($web)) {
  write-host "`nAvailable Names:"
  $webs | Format-Table
  return
}

# note: directly use $Verbose not work
# if ($PsBoundParameters.Verbose) {
#   $webs | format-table
# }
$web = $webs[$web] ?? $web
Write-Verbose $web
# edge://flags/#allow-insecure-localhost
saps msedge -ArgumentList @( '--ignore-certificate-errors', '--ignore-urlfetcher-cert-requests', "--profile-directory=`"$prof`"", $web)

# note: it's linked
# ni -Type HardLink M:\Work\Slb-Presto\drilldev\command\Web\Web.ps1 -Value M:\Script\Pwsh\Cmdlet\s\Command\Web\Web.ps1