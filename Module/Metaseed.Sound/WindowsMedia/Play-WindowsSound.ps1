function GetWindowsSounds {
  [CmdletBinding()]
  param (
    [Parameter()]
    $wordToComplete
  )
  $Sounds = @(Get-ChildItem "$env:windir\Media\Windows *.wav" | 
  % { $_.BaseName.TrimStart('Windows ') }) | 
  ? { 
    if($wordToComplete) {
      return $_ -like ($wordToComplete -split '' -join '*').TrimStart('*') 
    } else {
      return $_
    }
  }|
  % {
    if($_.Contains(' ')){
      return "'$_'"
    }else{
      return $_
    }
  }
  return $Sounds
}

function Play-WindowsSound {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0)]
    $name = 'Print complete',

    [Parameter()]
    [switch]
    $sync,

    # list all the sounds
    [Parameter()]
    [switch]$list
  )
  if($list) {
    GetWindowsSounds ''
    return
  }

  $path = "$env:windir\Media\Windows $name.wav"
  if(!(Test-Path $path)) {
    Write-error "sound $path does not exist"
    return
  }
  Play-Sound $path -sync:$sync
}
#Note: directly use ArgumentCompleter and call GetWindowsSounds in it's script block not works!
Register-ArgumentCompleter -CommandName 'Play-WindowsSound' -ParameterName 'name' -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
  $Sounds = GetWindowsSounds $wordToComplete
  return $Sounds
}
# ipmo Metaseed.Sound -fo; 