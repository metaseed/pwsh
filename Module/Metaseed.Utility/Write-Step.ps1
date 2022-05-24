function Write-Step($message) {
  # Write-Progress -Activity  $message -status " " -Id 0
  # $step = $script:step++ $script scope not working wellwrite
  $icon = $env:WT_SESSION ? "step﯀ ": 'Step:=>'
  Write-Host "$icon $message" -ForegroundColor Blue -BackgroundColor Yellow -NoNewline
  Write-Host ""
}

function Write-SubStep($message) {
  # Write-Progress -Activity  $message -status " " -Id 0
  $icon = $env:WT_SESSION ? "SubStep ": 'SubStep:->'

  Write-Host "   $icon$message" -ForegroundColor Green
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