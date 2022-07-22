function Speak-Countdown {
  param([int]$StartNumber = 10, [string]$language)

  try {
    for ([int]$i = $StartNumber; $i -ge 0; $i--) {
      Speak-Text $i $language -sync
      start-sleep -milliseconds 200
    }
  } catch {
    "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
  }
}