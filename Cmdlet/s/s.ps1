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
      return Complete-Command "$PSScriptRoot\_Command" $wordToComplete
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
  return Get-DynCmdParam $PSScriptRoot\_Command $Command
}

end {
  if ($code) {
    code $PSScriptRoot\..\..
    return
  }

  if (!$Command) {
    Write-AllSubCommands $PSScriptRoot\_Command
    return
  }

  $file = Get-AllPwshFiles $PSScriptRoot\_Command | ? { $_.BaseName -eq $Command }
  if ($null -eq $file) {
    Write-Host "Command $Command not found"
    return
  }

  if ($Help) {
    Get-Help $file -Full
    return
  }

  $null = $PSBoundParameters.Remove('Command')
  # cmd folder and lib folder could be used inside subcommand
  $__CmdFolder = "$PSScriptRoot\_Command"
  $__LibFolder = "$PSScriptRoot\_Lib"
  $__PWSHFolder = Resolve-Path "$PSScriptRoot\..\..\"
  & $file @PSBoundParameters
}
