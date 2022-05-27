function Play-Sound {
  [CmdletBinding()]
  param (
    [Parameter()]
    $soundPath
  )
  if (!(Test-Path $soundPath)) {
    Write-Warning "Play-Sound: $soundPath not found"
    return
  }
  # https://docs.microsoft.com/en-us/dotnet/api/system.media.soundplayer?view=dotnet-plat-ext-6.0
  $PlayWav = New-Object System.Media.SoundPlayer
  $PlayWav.SoundLocation = $soundPath
  $PlayWav.playsync()
}

# PlaySound "$env:windir\media\Windows Logon.wav"