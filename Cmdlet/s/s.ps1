<#
s: shell
#>
param(
  [ArgumentCompleter( {
      param (
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters )
      return Complete-Command 'ShellCmd' "$PSScriptRoot\_Commands" $wordToComplete
    })]
  [Parameter(Position = 0)]
  $Command,

  [switch]
  $Help,

  [switch]
  [Alias('c')]
  $code
)

dynamicparam {
  $Command = $PSBoundParameters['Command']
  return Get-DynCmdParam 'ShellCmd' "$PSScriptRoot\_Commands" $Command
}

begin {
  $error.Clear()
}

end {
  $__CmdCache = 'ShellCmd'

  if ($code) {
    code $PSScriptRoot\..\..
    return
  }

  if (!$Command) {
    Write-AllSubCommands "$PSScriptRoot\_Commands"
    return
  }

  $file = Find-CmdItem $__CmdCache "$PSScriptRoot\_Commands" $Command '*.ps1'
  if ($null -eq $file) {
    Write-Host "Command $Command not found"
    return
  }

  if ($Help) {
    Get-Help $file -Full
    return
  }

  # cmd folder and lib folder could be used inside subcommand
  $__CmdFolder = "$PSScriptRoot\_Commands"
  $__LibFolder = "$PSScriptRoot\_Lib"
  $__RootFolder = Resolve-Path "$PSScriptRoot\..\.."

  $null = $PSBoundParameters.Remove('Command')
  & $file @PSBoundParameters

  $err = $error | ? {
    $_.InvocationInfo.Line -notmatch '-ErrorAction\s+SilentlyContinue'
  }

  if ($err) {
    Write-AnsiText "Errors:" -Blink -ForegroundColor Red -Inverted
    $err
  }
}
