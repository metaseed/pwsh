function Write-Attention {
  param (
    [string]$message,
    [switch]$replay = $fasle,
    [switch]$Speak,
    [Object]$SpeakMessage = $null
  )
  if (!$replay) {
    if ($Speak || $SpeakMessage) { Speak-Text "Attention: $($SpeakMessage ?? $message)" }

    WriteStepMsg @{type = 'Attention'; message = $message}
  }
  $icon = $env:WT_SESSION ? '🚩' : '!'
  $indents = ' ' * (($__PSReadLineSessionScope.indents + 1) * $__IndentLength)
  Write-Host $indents -NoNewline
  Write-Host "▐" -ForegroundColor Blue  -NoNewline
  Write-Host -ForegroundColor DarkBlue  "${icon}Attention:" -BackgroundColor Yellow -NoNewline
  Write-Host " $message" -ForegroundColor Blue

}