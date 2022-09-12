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

<#
256 colors
# `e=$([char]27)
# `e[<Foreground or Background Code>;5;(color)
# 5: 256 colors
# 38: forground
# 48: background

# 256colors:
# 0-7: standard colors
# 8-15: high intensity colors
# 16-231: 6 × 6 × 6 cube (216 colors)
# 232-255: grayscale
#>

function Write-AnsiText {
  [CmdletBinding(DefaultParameterSetName = "8bit")]
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

    [Parameter(position = 0, ParameterSetName = '8bit')]
    [ForegroundColorAnsi]
    $ForegroundColor,
    [Parameter(position = 1, ParameterSetName = '8bit')]
    [BackgroundColorAnsi]
    $BackgroundColor,

    [Parameter(position = 0, ParameterSetName = '256bit')]
    [int]
    [ValidateRange(0, 255)]
    $Foreground256Bits,
    [Parameter(position = 1, ParameterSetName = '256bit')]
    [int]
    [ValidateRange(0, 255)]
    $Background256Bits,

    [Parameter(position = 0, ParameterSetName = 'rgb')]
    [int[]]
    [ValidateScript({
        if ($_ -lt 0 -or $_ -gt 255) { throw "$_ is out or range[0,255]" }
        return $true
      })]
    $ForegroundRGB,
    [Parameter(position = 1, ParameterSetName = 'rgb')]
    [int[]]
    [ValidateScript({
      if ($_ -lt 0 -or $_ -gt 255) { throw "$_ is out or range[0,255]" }
      return $true
    })]
    $BackgroundRGB,

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

  if ($pscmdlet.ParameterSetName -eq '8bit') {
    if ($ForegroundColor) { $fgc = ";$($ForegroundColor.value__)" }
    if ($BackgroundColor) { $bgc = ";$($BackgroundColor.value__)" }
  }
  elseif ($pscmdlet.ParameterSetName -eq '256bit') {
    $fgc = $Foreground256Bits
    $bgc = $Background256Bits
  }
  elseif ($pscmdlet.ParameterSetName -eq 'rgb') {
    if($ForegroundRGB.Count -ne 3) {throw "ForgroundRGB should have 3 elements(RGB)"}
    if($BackgroundRGB.Count -ne 3) {throw "BackgroundRGB should have 3 elements(RGB)"}
    $fgc = $ForegroundRGB -join ';'
    $bgc = $BackgroundRGB -join ';'
  }

  if ($Underlined) { $und = ';4' }
  if ($Blink) { $blk = ';5' }
  if ($Bold) { $bld = ';1' }
  if ($Inverted) { $inv = ";7" }
  if ($pscmdlet.ParameterSetName -eq '8bit') {
    Write-Host "`e[${fgc}${bgc}${bld}${inv}${und}${blk}m$text`e[0m" -NoNewline:$NoNewLine
  }
  elseif ($pscmdlet.ParameterSetName -eq '256bit') {
    Write-Host "`e[38;5;${fgc}${bld}${inv}${und}${blk}m`e[48;5;${bgc}m$text`e[0m" -NoNewline:$NoNewLine
  }
  elseif ($pscmdlet.ParameterSetName -eq 'rgb') {
    Write-Host "`e[38;2;${fgc}${bld}${inv}${und}${blk}m`e[48;2;${bgc}m$text`e[0m" -NoNewline:$NoNewLine
  }
}

function Show-AnsiColors8Bits {
  $fgColors = [Enum]::GetValues([ForegroundColorAnsi])
  $bgColors = [Enum]::GetValues([BackgroundColorAnsi])
  foreach ($fgColor in $fgColors) {
    $fgText = "$fgColor"
    foreach ( $bgColor in $bgColors) {
      $bgText = "$bgColor"
      Write-Output "$($fgColor.value__) `e[$($fgColor.value__)mfg:$($fgText.PadRight(12))    `e[0m`e[$($fgColor.value__);$($bgColor.value__)m $("fg:${fgText}; bg:$bgText".PadRight(32))`e[0m    `e[0m`e[$($bgColor.value__)mbg:$($bgText.PadRight(12))`e[0m"
    }
  }
  @'
  ANSI/VT100 escape sequences can be used in every programming languages.
  `e: escape character 27(decimal),033(oct) 0x1B(hex); `e=$([char]27)
  [: introducer
  ;: argument seperator
  m: SGR(Select/Set Graphics Rendition) function

  0: reset all last set attributes; `e[0m

  Style         Sequence    Reset Sequence
  Bold 1:       `e[1m     `e[21m
  Dim 2:        `e[2m     `e[22m
  Italic 3:     `e[3m     `e[23m
  Underlined 4: `e[4m     `e[24m
  blink 5:      `e[5m     `e[25m
  Inverted 7:   `e[7m     `e[27m
  Hidden 8:     `e[8m     `e[28m   for password

  Color           Foreground Code   Background Code
  Black           30                40
  Red             31                41
  Green           32                42
  Yellow          33                43
  Blue            34                44
  Magenta         35                45
  Cyan            36                46
  Light gray      37                47
  Dark gray       90                100
  Light red       91                101
  Light green     92                102
  Light yellow    93                103
  Light blue      94                104
  Light magenta   95                105
  Light cyan      96                106
  White           97                107

example:
"`e[33;44;5;4;3mHello`e[0m"
'@
  "`e[33;44;5;4;3mHello`e[0m"

}

function Show-ConsoleColors {
  Write-Host 'System.ConsoleColor colors that can be used in Write-Host:'
  [Enum]::GetValues([System.ConsoleColor]) | Foreach-Object { Write-Host $_ -ForegroundColor $_ }
}
function Show-AnsiColors256Bits {
  Write-Output "`n`e[1;4m256-Color Foreground & Background Charts`e[0m"
  foreach ($bright in 0, 1) {
    $brightColor = $bright ? ';1' : ''
    foreach ($fgbg in 38, 48) {
      if ($fgbg -eq 38) {
        Write-Host "Foreground Colors$($bright ? '(Bright)' : ''):"
      }
      else {
        Write-Host "Background Colors$($bright ? '(Bright)' : ''):"
      }
      # foreground 38/background 48 switch
      foreach ($color in 0..255) {
        # color range
        #Display the colors
        $field = "$color".PadLeft(4)  # pad the chart boxes with spaces
        Write-Host -NoNewLine "`e[$fgbg;5;${color}${brightColor}m$field `e[0m"
        #Display 6 colors per line
        if ( (($color + 1) % 6) -eq 4 ) { Write-Output "`r" }
      }
      Write-Output `n
    }
  }

}

Export-ModuleMember Show-AnsiColors8Bits, Show-AnsiColors256Bits, Show-ConsoleColors