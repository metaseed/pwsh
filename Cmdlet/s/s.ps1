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
      return Complete-Command "$PSScriptRoot\Command" $wordToComplete
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
  return Get-DynCmdParam "$PSScriptRoot\Command" $Command
}
begin {
  $error.Clear()
}

end {
  if ($code) {
    code $PSScriptRoot\..\..
    return
  }

  if (!$Command) {
    Write-AllSubCommands "$PSScriptRoot\Command"
    return
  }

  $file = Get-AllPwshFiles "$PSScriptRoot\Command" | ? { $_.BaseName -eq $Command }
  if ($null -eq $file) {
    Write-Host "Command $Command not found"
    return
  }

  if ($Help) {
    Get-Help $file -Full
    return
  }

  # cmd folder and lib folder could be used inside subcommand
  $__CmdFolder = "$PSScriptRoot\Command"
  $__LibFolder = "$PSScriptRoot\_Lib"
  $__PWSHFolder = Resolve-Path "$PSScriptRoot\..\..\"
  $null = $PSBoundParameters.Remove('Command')
  & $file @PSBoundParameters
  $error
}
