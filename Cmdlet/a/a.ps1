<#
a: Apps in $env:MS_App (c:\app)
invoke: a <cmd> -- args_to_cmd

#>
[CmdletBinding()]
param(
  [ArgumentCompleter({
      param (
        $appName,
        $parameterName,
        $wordToComplete,
        $appAst,
        $fakeBoundParameters )
      $commands = Complete-Command 'app_commands' "$PSScriptRoot\_Commands" $wordToComplete '*.ps1'
      $apps = Complete-Command 'app' $env:MS_App $wordToComplete '*.exe'
      $handlers = Complete-Command 'app_handlers' "$PSScriptRoot\_handlers" $wordToComplete '*.ps1'
      $cmds = ( $handlers + $apps + $commands) | get-unique
      return $cmds
    })]
  [Parameter(Position = 0)]
  $app,
  [switch]
  [Alias('s')]
  $showFolder,
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
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
  # [string][Parameter(position = 1)]$arg
)
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
dynamicparam {
  # Show-MessageBox "$PSScriptRoot\_args"
  if (!$app) {
    return
  }

  $a = Get-AppDynamicArgument 'app_args' $app "$PSScriptRoot\_args"
  if ($a.Count -ne 0) {
    # Show-MessageBox "$($a)"
    return $a
  }

  $HandlerCache = Get-CmdsFromCache 'app_commands' "$PSScriptRoot\_Commands" '*.ps1'
  if ($HandlerCache) {
    $handler = $HandlerCache[$app]
    if ($handler) {
      $p = Get-DynCmdParam 'app_commands_params' "$PSScriptRoot\_Commands" $app
      return $p
    }
  }
}

end {
  if($showFolder){
    start $env:MS_App
    return
  }

  if (!$app) {
    Write-FileTree $env:MS_App @('\.exe$')
    return
  }

  $update = $false

  do {
    $CmdCache = Get-CmdsFromCache 'app_commands' "$PSScriptRoot\_Commands" '*.ps1' -update:$update
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

    $file = Find-CmdItem 'app' $env:MS_App  $app '*.exe' -updateScript { param($cacheValue, $Command) return $update }
    Write-Verbose "File: $file"

    $HandlerCache = Get-CmdsFromCache 'app_handlers' "$PSScriptRoot\_handlers" '*.ps1' -update:$update
    if ($HandlerCache) {
      $handler = $HandlerCache[$app]
      Write-Verbose "handler: $handler"
      if ($handler) {
        & $handler $file $Remaining
        return
      }
    }
    # retry if we are here
    if ($null -eq $file) {
      Write-Verbose "Command $app not found, retry..."
      # only repeat one time if need to update
      $update = !$update
    }
  } while ($update)

if(!$file){
  write-error "can not find app: $app"
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