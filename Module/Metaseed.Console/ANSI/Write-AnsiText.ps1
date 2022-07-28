enum ForegroundColorAnsi {
  Black = 30
  Red = 31
  Green = 32
  Yellow = 33
  Blue = 34
  Magenta = 35
  Cyan = 36
  LightGray = 37
  DarkGray = 90
  LightRed = 91
  LightGreen = 92
  LightYellow = 93
  LightBlue = 94
  LightMagenta = 95
  LightCyan = 96
  White = 97
}

enum BackgroundColorAnsi {
  Black = 40
  Red = 41
  Green = 42
  Yellow = 43
  Blue = 44
  Magenta = 45
  Cyan = 46
  LightGray = 47
  DarkGray = 100
  LightRed = 101
  LightGreen = 102
  LightYellow = 103
  LightBlue = 104
  LightMagenta = 105
  LightCyan = 106
  White = 107
}

function Write-AnsiText {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]
    $text = @"
    __________               .__          _____          __                                      
    \______   \__  _  _______|  |__      /     \   _____/  |______    __________   ____    ____  
     |     ___/\ \/ \/ /  ___/  |  \    /  \ /  \_/ __ \   __\__  \  /  ___/  _ \ /    \  / ___\ 
     |    |     \     /\___ \|   Y  \  /    Y    \  ___/|  |  / __ \_\___ (  <_> )   |  \/ /_/  >
     |____|      \/\_//____  >___|  /  \____|__  /\___  >__| (____  /____  >____/|___|  /\___  / 
                           \/     \/           \/     \/          \/     \/           \//_____/  
"@,
    [ForegroundColorAnsi]
    $ForegroundColor,
    [BackgroundColorAnsi]
    $BackgroundColor,
    [switch]
    $Inverted,
    [switch]
    $Underlined,
    [switch]
    $Blink,
    [switch]
    $Bold,
    [switch]$NoNewLine
  )
  if($ForegroundColor) {$fgc = ";$($ForegroundColor.value__)"}
  if($BackgroundColor) {$bgc = ";$($BackgroundColor.value__)"}
  if($Underlined){$und = ';4'}
  if($Blink) {$blk = ';5'}
  if($Bold) {$bld = ';1'}
  if($Inverted) {$inv = ";7"}
  Write-Host "`e[${fgc}${bgc}${bld}${inv}${und}${blk}m$text`e[0m" -NoNewline:$NoNewLine
}
