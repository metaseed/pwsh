<#
a: Application
#>
param(
  [ArgumentCompleter( {
      param ( 
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters )
      return Complete-Command $env:MS_App $wordToComplete '*.exe'
    })]
  [Parameter(Position = 0)]
  $Command,
  [parameter(mandatory=$false, position=1, ValueFromRemainingArguments=$true)]$Remaining
)

end {
  if (!$Command) {
    Write-FileTree $env:MS_App @('\.exe$')
    return
  }

  $file = Get-AllCmdFiles $env:MS_App '*.exe' | ? { $_.BaseName -eq $Command }
  if ($null -eq $file) {
    Write-Host "Command $Command not found"
    return
  }

  & $file @Remaining
}
