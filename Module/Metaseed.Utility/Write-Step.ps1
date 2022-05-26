
function Write-Step($message) {
  # Write-Progress -Activity  $message -status " " -Id 0
  $step = $__Session.step++
  $__Session.subStep = 0
  $__Session.execute = 0
  $__Session.indents = 0
  $icon = "Step${step}:==>"
  Write-Host "$icon $message" -ForegroundColor Blue -BackgroundColor Yellow -NoNewline
  Write-Host ""
}

function Write-SubStep($message) {
  $subStep = $__Session.subStep++
  # Write-Progress -Activity  $message -status " " -Id 0
  $icon = "SubStep${subStep}:-->"
  $__Session.indents = 1
  $__Session.execute = 0

  $indents = ' ' * $__IndentLength
  Write-Host "$indents$icon $message" -ForegroundColor Green
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