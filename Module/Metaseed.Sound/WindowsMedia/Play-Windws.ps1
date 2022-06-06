function Play-Windows {
  [CmdletBinding()]
  param (
    [ArgumentCompleter( {
      param ( 
          $commandName,
          $parameterName,
          $wordToComplete,
          $commandAst,
          $fakeBoundParameters )
          
      $cmds = Get-AllPwshFiles $PSScriptRoot\Command | % { $_.BaseName } }
      return $true
      )]
    [Parameter()]
    $name = 1
  )
  $mediaDir = "$env:windir\Media"
  
  $index = "$index".PadLeft(2, '0')
  $path = "$env:windir\Media\Windows $name.wav"
  Play-Sound $path
}