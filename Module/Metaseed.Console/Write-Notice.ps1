function Write-Notice {
  param (
    [string]$message,
    [switch]$replay = $fasle
  )
  if (! $replay) {
    WriteStepMsg @{type = 'Notice'; message = $message }
  }
  $icon = $env:WT_SESSION ? '🔔' : '#'
  $indents = ' ' * (($__Session.indents + 1) * $__IndentLength)
  Write-Host $indents -NoNewline
  Write-Host "▐" -ForegroundColor Green  -NoNewline
  Write-Host -ForegroundColor DarkGreen  "${icon}Notice:" -BackgroundColor Yellow -NoNewline
  Write-Host " $message" -ForegroundColor Green
  
}