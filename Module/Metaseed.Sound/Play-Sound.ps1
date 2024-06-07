function Play-Sound {
  [CmdletBinding()]
  param (
    [Parameter()]
    $soundPath,

    [Parameter()]
    [switch]
    $sync
  )

  if (!(Test-Path $soundPath)) {
    Write-Error "Play-Sound: $soundPath not found"
    return
  }

  # https://docs.microsoft.com/en-us/dotnet/api/system.media.soundplayer?view=dotnet-plat-ext-6.0
  $PlayWav = New-Object System.Media.SoundPlayer
  $PlayWav.SoundLocation = $soundPath
  if ($sync) {
    $PlayWav.playsync()
  }
  else {
    $PlayWav.play()
  }
}

# PlaySound "$env:windir\media\Windows Logon.wav"