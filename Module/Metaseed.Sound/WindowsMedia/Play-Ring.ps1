function Play-Ring {
  [CmdletBinding()]
  param (
    [Parameter()]
    [ValidateRange(1,10)]
    $index = 1,

    [Parameter()]
    [switch]
    $sync
  )
  $index = "$index".PadLeft(2, '0')
  $path = "$env:windir\Media\Ring$index.wav"
  Play-Sound $path -sync:$sync
}

#currently by default async
#$null = Play-Ring 1& # not needed