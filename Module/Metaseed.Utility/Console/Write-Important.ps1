function Write-Important {
  param (
    [string]$message,
    [switch]$replay = $fasle
  )
  if (! $replay) {
    WriteStepMsg @{type = 'Important'; message = $message }
  }
  $icon = $env:WT_SESSION ? '' : '!'
  $indents = ' ' * (($__Session.indents + 1) * $__IndentLength)
  Write-Host -ForegroundColor DarkYellow  "$indents${icon}Attention: $message"
  
}