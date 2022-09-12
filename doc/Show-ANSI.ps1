# https://duffney.io/usingansiescapesequencespowershell/#:~:text=ANSI%20escape%20sequences%20are%20often,character%20representing%20an%20escape%20character
# https://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_ansi_terminals?view=powershell-7.2
# https://4sysops.com/archives/using-powershell-with-psstyle/

# https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
# ansi text good document: https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797


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

for ($i=1;$i -le 100;$i++){Write-Host -NoNewline "`r" $i;sleep 1}

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

