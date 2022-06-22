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

      $word = ($wordToComplete -split '' -join '*').Substring(1)
      return $appsKeys | ? {
        $_ -like "*${word}*"
      }
    })]
  [Parameter(Position = 0)]
  [string]$app,
    [string]
    $repo = 'pwsh'
)

. $psscriptroot\_config.ps1

saps msedge $apps[$repo]
