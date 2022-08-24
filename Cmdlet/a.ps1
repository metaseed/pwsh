<#
a: Application
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
  [Parameter(mandatory=$false, position=1,DontShow, ValueFromRemainingArguments=$true)]$Remaining,
  # used when $remaining not work. i.e. a ffmpeg -y -i matrixRain.webm -vf palettegen palette.png, not work, because of the -i, is ambiguous to -information and -InformationVariable
  # we could do: a ffmpeg -arg "-y -i matrixRain.webm -vf palettegen palette.png"
  [string][Parameter()]$arg
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
if($arg) {
  $null = saps $file $arg -NoNewWindow -PassThru -Wait
} else {
  write-host 'b'
  & $file @Remaining
}
}
