function GetGifs {
  [CmdletBinding()]
  param (
    [Parameter()]
    $wordToComplete
  )
  $gifs = @(Get-ChildItem "$psscriptroot\gifs" -Recurse |% { $_.BaseName})|
  ? { 
    if($wordToComplete) {
      return $_ -like ($wordToComplete -split '' -join '*')
    } else {
      return $_
    }
  }
  return $gifs
}
<#
.SYNOPSIS play a gif for a set seconds
#>
function Play-WTBGGif {
    param(
      # if dir: random gif in dir, if file, play that gif
      [Parameter( Position=0)]
      $name = 'fireworks',
      [Parameter( Position=1)]
      [int]$durationInseconds = 6,
      [Parameter( Position=2)]
      [ValidateSet('center','topLeft','bottomLeft','left','topRight','bottomRight','right','top','bottom')]
      [string]$alignment = 'center',
      [ValidateSet('none','uniformToFill','fill','uniform')]
      [string]$stretchMode = 'none'

    )
    $it = Get-ChildItem "$psscriptroot\gifs" -Recurse | Where-Object { $_.BaseName -eq $name } 
    if($it.Attributes -eq 'Directory') {
      $it = Get-ChildItem "$psscriptroot\gifs\$name\*.gif" -Recurse | get-Random
    }
    $str =  '{"backgroundImage": ' +  (ConvertTo-Json "$it") + ',"backgroundImageStretchMode": "'+$stretchMode +'","backgroundImageAlignment": "'+ $alignment +'","backgroundImageOpacity":0.8}'
    Set-WTBgImg defaults $durationInseconds $str
}


#Note: directly use ArgumentCompleter and call GetWindowsSounds in it's script block not works!
Register-ArgumentCompleter -CommandName 'Play-WTBGGif' -ParameterName 'name' -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
  $gifs = GetGifs $wordToComplete
  return $gifs
}