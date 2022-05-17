function Write-Step($message) {
  # Write-Progress -Activity  $message -status " " -Id 0

  Write-Host "==> $message" -ForegroundColor Blue -BackgroundColor Yellow -NoNewline
  Write-Host ""
}

function Write-SubStep($message) {
  # Write-Progress -Activity  $message -status " " -Id 0

  Write-Host "  --> $message" -ForegroundColor Green
}

function Write-Important {
  param (
      [string]$msg
  )
  Write-Host -ForegroundColor DarkYellow  "⚠Attention: $msg"
  
}

Export-ModuleMember Write-SubStep, Write-Important

# get all colors:
# [enum]::GetValues([System.ConsoleColor]) | Foreach-Object {Write-Host $_ -ForegroundColor $_ }