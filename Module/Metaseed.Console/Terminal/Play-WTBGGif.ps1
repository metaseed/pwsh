function GetGifs {
  [CmdletBinding()]
  param (
    [Parameter()]
    $wordToComplete
  )
  $gifs = @(Get-ChildItem "$psscriptroot\gifs" -include "*.gif"|% { $_.BaseName})|
  ? { 
    if($wordToComplete) {
      return $_ -like ($wordToComplete -split '' -join '*').TrimStart('*')
    } else {
      return $_
    }
  }
  return $gifs
}

function Play-WTBGGif {
    param(
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
    $str =  '{"backgroundImage": ' +  (ConvertTo-Json "$psscriptroot\gifs\$name.gif") + ',"backgroundImageStretchMode": "'+$stretchMode +'","backgroundImageAlignment": "'+ $alignment +'","backgroundImageOpacity":0.8}'
    Set-WTBgImg defaults $durationInseconds $str
}


#Note: directly use ArgumentCompleter and call GetWindowsSounds in it's script block not works!
Register-ArgumentCompleter -CommandName 'Play-WTBGGif' -ParameterName 'name' -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
  $gifs = GetGifs $wordToComplete
  return $gifs
}