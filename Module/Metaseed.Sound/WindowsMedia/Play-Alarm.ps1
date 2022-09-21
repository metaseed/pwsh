function Play-Alarm {
  [CmdletBinding()]
  param (
    [ValidateRange(1,10)]
    $index = 1,

    [Parameter()]
    [switch]
    $sync
  )
  $index = "$index".PadLeft(2, '0')
  $path = "$env:windir\Media\Alarm$index.wav"
  Play-Sound $path -sync:$sync
}

# Play-Alarm 1