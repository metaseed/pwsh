# https://duffney.io/usingansiescapesequencespowershell/#:~:text=ANSI%20escape%20sequences%20are%20often,character%20representing%20an%20escape%20character
# https://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_ansi_terminals?view=powershell-7.2

# ANSI/VT100 escape sequences can be used in every programming languages.
# `e: escape character 27(decimal),033(oct) 0x1B(hex)
# [: introducer
# ;: argument seperator
<#
0: reset all last set attributes; `e[0m

Style         Sequence    Reset Sequence
Bold 1:       `e[1m     `e[21m
Dim 2:        `e[2m     `e[22m
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
#>

# 36: Cyan
# m: SGR(Select/Set Graphics Rendition) function
Write-Host "8 bits colors"
$fgColors = '30', '31', '32', '33', '34', '35', '36', '37'
$bgColors = '40', '41', '42', '43', '44', '45', '46', '47'

foreach ($fgColor in $fgColors) {
  $fgText = $($fgColor.PadRight((3)))
  foreach ( $bgColor in $bgColors) {
    $bgText = $($bgColor.PadRight((3)))
    Write-Output "`e[$($fgColor)mfg$fgText`e[0m`e[$fgColor;$($bgColor)m fg${fgText}:bg$bgText `e[0m`e[$($bgColor)mbg$bgText`e[0m"
  }
}

# `e=$([char]27)
# `e[<Foreground or Background Code>;5;(color)
# 5: 256 colors
#
# colors:
# 0-7: standard colors
# 8-15: high intensity colors
# 16-231: 6 × 6 × 6 cube (216 colors)
# 232-255: grayscale
# 1: bright color

Write-Output "`n`e[1;4m256-Color Foreground & Background Charts`e[0m"
foreach ($bright in 0, 1) {
  if($bright){Write-Host "bright colors"}
  $brightColor = $bright ? ';1' : ''
  foreach ($fgbg in 38, 48) {
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


$asciiArt = @"
Blink
     __ __  ____ ___________   __             
  __/ // /_/ __ \ ___/__  / | / /___ _      __
 /_  _  __/ /_/ \__ \  / /  |/ / __ \ | /| / /
/_  _  __/ ____/__/ / / / /|  / /_/ / |/ |/ / 
 /_//_/ /_/   /____/ /_/_/ |_/\____/|__/|__/  
                                              
"@

Write-Output "`e[5;36m$asciiArt`e[0m";

# combination would use ';' too
Write-Output @"
`e[1mBold`e[0m
`e[4mUnderLined`e[0m
`e[7mInverted`e[27m
`e[1m`e[4m`e[7;34;43mBold&UnderLined&Inverted&BlueFore&YellowBack`e[0m
"@

foreach ($clbg in 40..47 + 100..107) {
  foreach ($clfg in 30..37 + 90..97) {
    foreach ($attr in 1..7) {
      Write-Host -NoNewLine "`e[$attr;$clbg;${clfg}m  ``e[$attr;$clbg;${clfg}m  `e[0m"
    }
    Write-Host ""
  }
}

# Write-Host "true color (16bits)"


write-host "cursor movement"
<#
{n}A: UP 
{n}B: Down
{n}C: Right
{n}D: Left

{n}E: next lines
{n}F: previous lines

{n}G: column
{n};{m}H: row n; col m

{n}K: Erase Line; n=0: curor to end; n=1: from cursor to start; n=2: entire line

{n}J: Clear Screen; 0: from cursor to end of screen; 1: to beginning to screen; 2: entire screen

s: save cursor position
u: restore curosor position
{n}P: delete charactors


#>
foreach ($step in 0..100) {
  Write-Output "$step%`e[1000D`e[1A"
  Start-Sleep 0.1
}

foreach ($step in 0..100) {
  $width = [Math]::Floor(($step +1) / 4)
  $progress = "[$( '#' * $width)$(' ' * (25-$width))]"
  Write-Output "$progress%`e[1000D`e[1A"
  Start-Sleep 0.1
}

# 1 is removed
Write-Output "`e[s1234567890`e[u`e[1P"
# startend is outputed 1-0 is removed
Write-Output "start`e[s`e[36m1234567890`e[u`e[K`e[0mend"

