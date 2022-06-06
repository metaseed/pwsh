function Play-Ring {
  [CmdletBinding()]
  param (
    [Parameter()]
    [ValidateRange(1,10)]
    $index = 1
  )
  $index = "$index".PadLeft(2, '0')
  $path = "$env:windir\Media\Ring$index.wav"
  Play-Sound $path
}

#currently by default async
#$null = Play-Ring 1& # not needed