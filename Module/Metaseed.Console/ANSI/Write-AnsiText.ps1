# https://en.wikipedia.org/wiki/ANSI_escape_code
$help = @'
ANSI/VT100 escape sequences can be used in every programming languages.
`e: escape character 27(decimal),033(oct) 0x1B(hex); `e=$([char]27)
[: introducer
;: argument seperator
m: SGR(Select/Set Graphics Rendition) function


first parameter:
0: reset all last set attributes; `e[0m

16 colors:
Color           Foreground Code   Background Code

Black           30                40
Red             31                41
Green           32                42
Yellow          33                43
Blue            34                44
Magenta         35                45
Cyan            36                46
Light gray      37                47
38: forground of 8bits or 256bits, then next paramert: 5 for 8bits and 2 for 24bits color
48: background of 8bits or 256bits
Dark gray       90                100
Light red       91                101
Light green     92                102
Light yellow    93                103
Light blue      94                104
Light magenta   95                105
Light cyan      96                106
White           97                107

Style         Sequence    Reset Sequence
Bold 1:       `e[1m     `e[21m
Dim 2:        `e[2m     `e[22m
Italic 3:     `e[3m     `e[23m
Underlined 4: `e[4m     `e[24m
Blink 5:      `e[5m     `e[25m
Inverted 7:   `e[7m     `e[27m
Hidden 8:     `e[8m     `e[28m   for password

16 Color-Values:
0-7: standard colors, 3bits
8-15: high intensity colors
example:
Foreground:Yellow 33; Background: Blue 44; Style: Blink 5, Underlined 4, Italic 3;
"`e[33;44;5;4;3mHello`e[0m"
forground: 93 lightYellow; background: 44 Blue
"`e[93;44mHello`e[0m"
----------------------------------------------------------------
8bits Endording:
 `e[<Foreground or Background Code>;5;(color)
 5: 8-bits 256 colors; 2: 24bits true color
 38: forground for 8bits or 24bits, folowwing parameters give details
 48: background for 8bits or 24bits

8bits example:
38: forground color; 5: 8bits; 33:fg; 5: blink; 4: underlined
"`e[38;5;33;5;4mHello`e[0m"
38: forground color; 5: 8bits; 33:fg; 48: background color; 5: 8bits; 77: bg; 5: blink; 4: underlined
"`e[38;5;33;48;5;77;5;4mHello`e[0m"

256 Color-Values:
  0-7: standard colors, 3bits
  8-15: high intensity colors
  16-231: 6 × 6 × 6 cube (216 colors)
  232-255: grayscale

# pwsh way
"$($PSStyle.Blink) $($PSStyle.Italic) $($PSStyle.Foreground.Yellow)Hello World$($PSStyle.Reset)"

'@


enum ForegroundColorAnsi {
  Black = 30 # 0x1E 0b0001 1110
  Red = 31
  Green = 32
  Yellow = 33
  Blue = 34
  Magenta = 35
  Cyan = 36
  LightGray = 37
  #38: forground for 8 or 256bits

  DarkGray = 90 # 0x5A 0b0101 1010
  LightRed = 91
  LightGreen = 92
  LightYellow = 93
  LightBlue = 94
  LightMagenta = 95
  LightCyan = 96
  White = 97
}

# for 16colors
enum BackgroundColorAnsi {
  Black = 40 # 0x28 0b0010 1000
  Red = 41 # 0x29 0b0010 1001
  Green = 42
  Yellow = 43
  Blue = 44
  Magenta = 45
  Cyan = 46
  LightGray = 47
  #48: backround for 8 or 256bits;folowwing parameters give details; 2: 256bits; 5: 8bits;

  DarkGray = 100 # 0x64 0b0110 1000
  LightRed = 101 # 0x65 0b0110 1001
  LightGreen = 102
  LightYellow = 103
  LightBlue = 104
  LightMagenta = 105
  LightCyan = 106
  White = 107
}


function Show-AnsiColors8Bits {
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
        # 5: 256 colors, it's not blink style here
        Write-Host -NoNewLine "`e[$fgbg;5;${color}${brightColor}m$field `e[0m"
        #Display 6 colors per line
        if ( (($color + 1) % 6) -eq 4 ) { Write-Output "`r" }
      }
      Write-Output `n
    }
  }
  write-host $help
}

function Get-AnsiText {
  [CmdletBinding(DefaultParameterSetName = "8bit")]
  param (
    [Parameter(Position = 0)]
    [string]
    $text = @"
    __________               .__          _____          __
    \______   \__  _  _______|  |__      /     \   _____/  |______    __________   ____    ____
     |     ___/\ \/ \/ /  ___/  |  \    /  \ /  \_/ __ \   __\__  \  /  ___/  _ \ /    \  / ___\
     |    |     \     /\___ \|   Y  \  /    Y    \  ___/|  |  / __ \_\___ (  <_> )   |  \/ /_/  >
     |____|      \/\_//____  >___|  /  \____|__  /\___  >__| (____  /____  >____/|___|  /\___  /
                           \/     \/           \/     \/          \/     \/           \//_____/
"@,

    [Parameter(position = 1, ParameterSetName = '8bit')]
    [ForegroundColorAnsi]
    $ForegroundColor,
    [Parameter(position = 2, ParameterSetName = '8bit')]
    [BackgroundColorAnsi]
    $BackgroundColor,

    [Parameter(position = 1, ParameterSetName = '256bit')]
    [int]
    [ValidateRange(0, 255)]
    $Foreground256Bits,
    [Parameter(position = 2, ParameterSetName = '256bit')]
    [int]
    [ValidateRange(0, 255)]
    $Background256Bits,

    [Parameter(position = 1, ParameterSetName = 'rgb')]
    [int[]]
    [ValidateScript({
        if ($_ -lt 0 -or $_ -gt 255) { throw "$_ is out or range[0,255]" }
        return $true
      })]
    $ForegroundRGB,
    [Parameter(position = 2, ParameterSetName = 'rgb')]
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
    $Bold)


  if ($pscmdlet.ParameterSetName -eq '8bit') {
    if ($ForegroundColor) { $fgc = ";$($ForegroundColor.value__)" }
    if ($BackgroundColor) { $bgc = ";$($BackgroundColor.value__)" }
  }
  elseif ($pscmdlet.ParameterSetName -eq '256bit') {
    $fgc = $Foreground256Bits
    $bgc = $Background256Bits
  }
  elseif ($pscmdlet.ParameterSetName -eq 'rgb') {
    if ($ForegroundRGB.Count -ne 3) { throw "ForgroundRGB should have 3 elements(RGB)" }
    if ($BackgroundRGB.Count -ne 3) { throw "BackgroundRGB should have 3 elements(RGB)" }
    $fgc = $ForegroundRGB -join ';'
    $bgc = $BackgroundRGB -join ';'
  }

  if ($Underlined) { $und = ';4' }
  if ($Blink) { $blk = ';5' }
  if ($Bold) { $bld = ';1' }
  if ($Inverted) { $inv = ";7" }

  if ($pscmdlet.ParameterSetName -eq '8bit') {
    return "`e[${fgc}${bgc}${bld}${inv}${und}${blk}m$text`e[0m"
  }
  elseif ($pscmdlet.ParameterSetName -eq '256bit') {
    return "`e[38;5;${fgc}${bld}${inv}${und}${blk}m`e[48;5;${bgc}m$text`e[0m"
  }
  elseif ($pscmdlet.ParameterSetName -eq 'rgb') {
    return "`e[38;2;${fgc}${bld}${inv}${und}${blk}m`e[48;2;${bgc}m$text`e[0m"
  }
  throw "wrong paramterSetName of Get-AnsiText"
}
function Write-AnsiText {
  [CmdletBinding(DefaultParameterSetName = "8bit")]
  param (
    [Parameter(Position = 0)]
    [string]
    $text = @"
    __________               .__          _____          __
    \______   \__  _  _______|  |__      /     \   _____/  |______    __________   ____    ____
     |     ___/\ \/ \/ /  ___/  |  \    /  \ /  \_/ __ \   __\__  \  /  ___/  _ \ /    \  / ___\
     |    |     \     /\___ \|   Y  \  /    Y    \  ___/|  |  / __ \_\___ (  <_> )   |  \/ /_/  >
     |____|      \/\_//____  >___|  /  \____|__  /\___  >__| (____  /____  >____/|___|  /\___  /
                           \/     \/           \/     \/          \/     \/           \//_____/
"@,

    [Parameter(position = 1, ParameterSetName = '8bit')]
    [ForegroundColorAnsi]
    $ForegroundColor,
    [Parameter(position = 2, ParameterSetName = '8bit')]
    [BackgroundColorAnsi]
    $BackgroundColor,

    [Parameter(position = 1, ParameterSetName = '256bit')]
    [int]
    [ValidateRange(0, 255)]
    $Foreground256Bits,
    [Parameter(position = 2, ParameterSetName = '256bit')]
    [int]
    [ValidateRange(0, 255)]
    $Background256Bits,

    [Parameter(position = 1, ParameterSetName = 'rgb')]
    [int[]]
    [ValidateScript({
        if ($_ -lt 0 -or $_ -gt 255) { throw "$_ is out or range[0,255]" }
        return $true
      })]
    $ForegroundRGB,
    [Parameter(position = 2, ParameterSetName = 'rgb')]
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

  [void]$PSBoundParameters.remove('NoNewline')
  $t = Get-AnsiText @PSBoundParameters
  if ($pscmdlet.ParameterSetName -eq '8bit') {
    Write-Host $t -NoNewline:$NoNewLine
  }
  elseif ($pscmdlet.ParameterSetName -eq '256bit') {
    Write-Host $t  -NoNewline:$NoNewLine
  }
  elseif ($pscmdlet.ParameterSetName -eq 'rgb') {
    Write-Host $t -NoNewline:$NoNewLine
  }
}

function Show-Ansi16Colors {
  Write-Host "``e[fg;bgm Hello ``e[0m"
  $fgColors = [Enum]::GetValues([ForegroundColorAnsi])
  $bgColors = [Enum]::GetValues([BackgroundColorAnsi])
  foreach ($fgColor in $fgColors) {
    $fgText = "$fgColor"
    foreach ( $bgColor in $bgColors) {
      $bgText = "$bgColor"
      Write-Output "$($fgColor.value__) `e[$($fgColor.value__)mfg:$($fgText.PadRight(12))    `e[0m`e[$($fgColor.value__);$($bgColor.value__)m $("fg:${fgText}; bg:$bgText".PadRight(32))`e[0m    $($bgColor.value__.ToString().PadRight(5)) `e[0m`e[$($bgColor.value__)mbg:$($bgText.PadRight(12))`e[0m"
    }
  }
  Write-Host $help

  Write-Host "``e[fg;bgm Hello``e[0m"
  Write-Host "i.e.:
  Write-Host `"``e[94;103m Hello ``e[0m`""

}

function Show-ConsoleColors {
  Write-Host 'System.ConsoleColor colors that can be used in Write-Host:'
  [Enum]::GetValues([System.ConsoleColor]) | Foreach-Object { Write-Host "$($_.value__) $_" -ForegroundColor $_ }
}


Export-ModuleMember @('Show-Ansi16Colors', 'Show-AnsiColors8Bits', 'Show-ConsoleColors', 'Get-AnsiText')