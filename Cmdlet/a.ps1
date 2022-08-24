<#
a: Apps in $env:MS_App (c:\app)
invoke: a <cmd> -- args_to_cmd
#>
[CmdletBinding()]
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
  [Parameter(mandatory = $false, position = 1, DontShow, ValueFromRemainingArguments = $true)]$Remaining,
  [string][Parameter(position = 1)]$arg
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
  if ($Remaining) {
    & $file @Remaining
  }
  else {
    saps $file $arg -NoNewWindow -Wait
  }
}