function GetGifs {
  [CmdletBinding()]
  param (
    [Parameter()]
    $wordToComplete
  )
  $isUrl = [uri]::IsWellFormedUriString($wordToComplete, 'Absolute') #-and ([uri] $uri).Scheme -in 'http', 'https'
  if ($isUrl -or (Test-Path $wordToComplete)) {
    return $wordToComplete
  }

  $gifFolder = $env:WTBackgroundImage ? @("$env:WTBackgroundImage", "$psscriptroot\res\gifs") : "$psscriptroot\res\gifs"

  $gifs = @(Get-ChildItem $gifFolder -Recurse | % { $_.BaseName }) |
  ? {
    if ($wordToComplete) {
      return $_ -like ($wordToComplete -split '' -join '*')
    }
    else {
      return $_
    }
  }
  return $gifs
}
<#
.SYNOPSIS play a gif for the set seconds
#>
function Show-WTBackgroundImage {
  param(
    # image name. if dir: random gif in dir, if file, play that gif
    [Parameter( Position = 0)]
    $image = 'fireworks',
    [Parameter( Position = 1)]
    [int]$durationInseconds = 6,
    [Parameter( Position = 2)]
    [string]$prof = 'defaults',
    [Parameter()]
    [ValidateSet('center', 'topLeft', 'bottomLeft', 'left', 'topRight', 'bottomRight', 'right', 'top', 'bottom')]
    [string]$alignment = 'center',
    [ValidateSet('none', 'uniformToFill', 'fill', 'uniform')]
    [string]$stretchMode = 'none',
    [ValidateRange(0,1)]
    [float]$backgroundImageOpacity = 0.8

  )
  $isUrl = [uri]::IsWellFormedUriString($image, 'Absolute') #-and ([uri] $uri).Scheme -in 'http', 'https'
  if ($isUrl -or (Test-Path $image)) {
    $it = $image
  }
  else {
    $gifFolder = $env:WTBackgroundImage ? @("$env:WTBackgroundImage", "$psscriptroot\res\gifs") : "$psscriptroot\res\gifs"

    $it = Get-ChildItem  $gifFolder -Recurse | Where-Object { $_.BaseName -eq $image }
    if ($it.PSIsContainer) {
      $it = Get-ChildItem $it -Recurse | ? {!($_.PSIsContainer)} | get-Random
      Write-Verbose $it
    }
  }
  $str = '{"backgroundImage": ' + (ConvertTo-Json "$it") + ',"backgroundImageStretchMode": "' + $stretchMode + '","backgroundImageAlignment": "' + $alignment + '","backgroundImageOpacity":' + $backgroundImageOpacity + '}'
  Set-WTBgImg $prof $durationInseconds $str
}


#Note: directly use ArgumentCompleter and call GetWindowsSounds in it's script block not works!
Register-ArgumentCompleter -CommandName 'Show-WTBackgroundImage' -ParameterName 'image' -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
  $gifs = GetGifs $wordToComplete
  return $gifs
}