function Write-Attention {
  param (
    [string]$message,
    [switch]$replay = $fasle
  )
  if (! $replay) {
    WriteStepMsg @{type = 'Important'; message = $message }
  }
  $icon = $env:WT_SESSION ? '🚩' : '!'
  $indents = ' ' * (($__Session.indents + 1) * $__IndentLength)
  Write-Host $indents -NoNewline
  Write-Host "▐" -ForegroundColor Blue  -NoNewline
  Write-Host -ForegroundColor DarkYellow  "${icon}Attention:" -BackgroundColor White -NoNewline
  Write-Host " $message" -ForegroundColor DarkYellow
  
}