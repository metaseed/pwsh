<#
.Example
  Speak-Countdown
  Speak-Countdown -language chinese
#>
function Speak-Countdown {
  param([int]$StartNumber = 10, [string]$language)

  for ([int]$i = $StartNumber; $i -ge 0; $i--) {
    Speak-Text $i $language -sync
    start-sleep -milliseconds 10
  }
}