<#
a: Apps in $env:MS_App (c:\app)
invoke: a <cmd> -- args_to_cmd
#>
[CmdletBinding()]
param(
  [ArgumentCompleter( {
      param (
        $appName,
        $parameterName,
        $wordToComplete,
        $appAst,
        $fakeBoundParameters )
      $apps = Complete-Command 'app' $env:MS_App $wordToComplete '*.exe'
      $handlers = Complete-Command 'app_handlers' "$PSScriptRoot\_handlers" $wordToComplete '*.ps1'
      $cmds = ($apps + $handlers) | get-unique
      return $cmds
    })]
  [Parameter(Position = 0)]
  $app,
  # used when $remaining not work. i.e. a ffmpeg -y -i matrixRain.webm -vf palettegen palette.png, not work, because of the -i, is ambiguous to -information and -InformationVariable
  # 1. the work around is use the below string parameter
  # we could do: a ffmpeg -arg "-y -i matrixRain.webm -vf palettegen palette.png"
  # 2. another perfered way: uses the '--' parameter as suggested in the post:
  # https://stackoverflow.com/questions/57705490/how-to-disable-short-parameter-names
  # so we do: a ffmpeg -- -y -i matrixRain.webm -vf palettegen palette.png               ****use this way****
  # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parsing?view=powershell-7.2#the-stop-parsing-token
  # --%: stop parsing, we can not have pwsh variable after it
  # --: end-of-parameters , and we can have pwsh variable after it
  # note: experiment feature in 7.2: https://docs.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.2#psnativecommandargumentpassing
  # do more exploration when it finally integrated. could we do it more naturely like?: a ffmpeg -y -i matrixRain.webm -vf palettegen palette.png
  [Parameter(mandatory = $false, position = 1, DontShow, ValueFromRemainingArguments = $true)]$Remaining
  # [string][Parameter(position = 1)]$arg
)
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
dynamicparam {
  if(!$app) {
    return
  }

  $a = Get-AppDynamicArgument $app "$PSScriptRoot\_args"
  if ($a.Count -ne 0) {
    return $a
  }

  $HandlerCache = Get-CmdsFromCacheAutoUpdate 'app_commands' "$PSScriptRoot\_commands" '*.ps1'
  if ($HandlerCache) {
    $handler = $HandlerCache[$app]
    if ($handler) {
      $p = Get-DynCmdParam 'app_commands_params' "$PSScriptRoot\_commands" $app
      return $p
    }
  }
}

end {
  if (!$app) {
    Write-FileTree $env:MS_App @('\.exe$')
    return
  }

  $CmdCache = Get-CmdsFromCacheAutoUpdate 'app_commands' "$PSScriptRoot\_commands" '*.ps1'
  if ($CmdCache) {
    $cmd = $CmdCache[$app]
    Write-Verbose "cmd: $cmd"
    if ($cmd) {
      $null = $PSBoundParameters.Remove('app')
      & $cmd @PSBoundParameters
      return
      # Write-Host "Remaining: $($Remaining -eq $null)" true
      # & $handler @Remaining # a set-sysinternalEula error: A positional parameter cannot be found that accepts argument '-Passthru'
    }
  }

  $file = Find-CmdItem 'app' $env:MS_App  $app '*.exe'
  Write-Verbose "File: $file"

  $HandlerCache = Get-CmdsFromCacheAutoUpdate 'app_handlers' "$PSScriptRoot\_handlers" '*.ps1'
  if ($HandlerCache) {
    $handler = $HandlerCache[$app]
    Write-Verbose "handler: $handler"
    if ($handler) {
      & $handler $file $Remaining
      return
    }
  }

  if ($null -eq $file) {
    Write-Host "Command $app not found"
    return
  }

  & $file @Remaining

  # if ($Remaining) {
  #   & $file @Remaining
  # }
  # else {
  #   # -Wait # remove wait to be faster but some app need the wait. i.e. lf
  #   saps $file $arg -NoNewWindow
  # }
}