function Write-Notice {
  param (
    [string]$message,
    [switch]$replay,
    [switch]$Speak,
    [Object]$SpeakMessage = $null
  )
  if (!$replay) {
    if ($Speak || $SpeakMessage) { Speak-Text "Notice: $($SpeakMessage ?? $message)" }
    WriteStepMsg @{type = 'Notice'; message = $message }
  }
  $icon = $env:TERM_NERD_FONT ? '🔔' : '#'
  $indents = ' ' * (($__PSReadLineSessionScope.indents + 1) * $__IndentLength)
  Write-Host $indents -NoNewline
  Write-Host "▐" -ForegroundColor Green  -NoNewline
  Write-Host -ForegroundColor DarkGreen  "${icon}Notice:" -BackgroundColor Yellow -NoNewline
  Write-Host " $message" -ForegroundColor Green
}