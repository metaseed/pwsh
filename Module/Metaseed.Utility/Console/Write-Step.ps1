
function Write-Step {
  param (
    [string]$message,
    [switch]$replay = $fasle
  )
  if (! $replay) {
    WriteStepMsg @{type = 'Step'; message = $message }
  }
  # Write-Progress -Activity  $message -status " " -Id 0
  $step = ++$__Session.step
  $__Session.subStep = $null
  $__Session.execute = 0
  $__Session.indents = 0
  $icon = "Step ${step}==>"
  Write-Host "▐" -ForegroundColor Blue  -NoNewline
  Write-Host "$icon $message" -ForegroundColor Blue -BackgroundColor Yellow -NoNewline
  Write-Host ""
}

function Write-SubStep {
  param (
    [string]$message,
    [switch]$replay = $fasle
  )
  if (! $replay) {
    WriteStepMsg @{type = 'SubStep'; message = $message }
  }

  $subStep = ++$__Session.subStep
  # Write-Progress -Activity  $message -status " " -Id 0
  $icon = "SubStep $($__Session.Step).${subStep}->>"
  $__Session.indents = 1
  $__Session.execute = 0

  $indents = ' ' * $__IndentLength
  Write-host "$indents" -NoNewline
  Write-Host "▐" -ForegroundColor Blue  -NoNewline
  Write-Host "$icon $message" -ForegroundColor Green -BackgroundColor White -NoNewline
  Write-Host ""
}

Export-ModuleMember Write-SubStep 

# get all colors:
# [enum]::GetValues([System.ConsoleColor]) | Foreach-Object {Write-Host "Command's Executed Steps, $_" -ForegroundColor blue -backgroundColor $_ }