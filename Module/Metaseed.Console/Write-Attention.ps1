function Write-Attention {
  param (
    [string]$message,
    [switch]$replay = $fasle
  )
  if (! $replay) {
    WriteStepMsg @{type = 'Attention'; message = $message }
  }
  $icon = $env:WT_SESSION ? '🚩' : '!'
  $indents = ' ' * (($__Session.indents + 1) * $__IndentLength)
  Write-Host $indents -NoNewline
  Write-Host "▐" -ForegroundColor Blue  -NoNewline
  Write-Host -ForegroundColor DarkBlue  "${icon}Attention:" -BackgroundColor Yellow -NoNewline
  Write-Host " $message" -ForegroundColor Blue
  
}