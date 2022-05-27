function Play-Alarm {
  [CmdletBinding()]
  param (
    [ValidateRange(1,10)]
    $index = 1
  )
  $index = "$index".PadLeft(2, '0')
  $path = "$env:windir\Media\Alarm$index.wav"
  Play-Sound $path
}

# Play-Alarm 1