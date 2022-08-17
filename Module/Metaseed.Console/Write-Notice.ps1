function Write-Notice {
  param (
    [string]$message,
    [switch]$replay,
    [switch]$NoSpeak,
    [Object]$SpeakMessage = $null
  )
  if (!$replay) {
    if (!$NoSpeak || $SpeakMessage) { Speak-Text "Notice: $($SpeakMessage ?? $message)" }
    WriteStepMsg @{type = 'Notice'; message = $message }
  }
  $icon = $env:WT_SESSION ? '🔔' : '#'
  $indents = ' ' * (($__PSReadLineSessionScope.indents + 1) * $__IndentLength)
  Write-Host $indents -NoNewline
  Write-Host "▐" -ForegroundColor Green  -NoNewline
  Write-Host -ForegroundColor DarkGreen  "${icon}Notice:" -BackgroundColor Yellow -NoNewline
  Write-Host " $message" -ForegroundColor Green
}