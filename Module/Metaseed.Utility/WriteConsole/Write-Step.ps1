
function Write-Step {
  param (
    [string]$message,
    [switch]$replay = $fasle
  )
  if (! $replay) {
    $__Session.Steps += @{type = 'Step'; message = $message }
  }
  # Write-Progress -Activity  $message -status " " -Id 0
  $step = ++$__Session.step
  $__Session.subStep = $null
  $__Session.execute = 0
  $__Session.indents = 0
  $icon = ":Step ${step}==>"
  Write-Host "$icon $message" -ForegroundColor Blue -BackgroundColor Yellow -NoNewline
  Write-Host ""
}

function Write-SubStep {
  param (
    [string]$message,
    [switch]$replay = $fasle
  )
  if (! $replay) {
    $__Session.Steps += @{type = 'SubStep'; message = $message }
  }

  $subStep = ++$__Session.subStep
  # Write-Progress -Activity  $message -status " " -Id 0
  $icon = ":SubStep $($__Session.Step).${subStep}->>"
  $__Session.indents = 1
  $__Session.execute = 0

  $indents = ' ' * $__IndentLength
  Write-Host "$indents$icon $message" -ForegroundColor Green -BackgroundColor White -NoNewline
  Write-Host ""
}

function Write-Important {
  param (
    [string]$message,
    [switch]$replay = $fasle
  )
  if (! $replay) {
    $__Session.Steps += @{type = 'Important'; message = $message }
  }
  $icon = $env:WT_SESSION ? '' : '!'
  $indents = ' ' * (($__Session.indents + 1) * $__IndentLength)
  Write-Host -ForegroundColor DarkYellow  "$indents${icon}Attention: $message"
  
}

function Show-Steps {
  if ($__Session.Steps.Count -eq 0) {
    Write-Host "No executed steps"
    return
  }
  Write-host "`nPreious Command's Executed Steps:" -ForegroundColor DarkYellow
  $__Session.Steps | % {
    if ($_.type -eq 'Step') {
      Write-Step $_.message -replay
    }
    elseif ($_.type -eq 'SubStep') {
      Write-SubStep $_.message -replay
    }
    elseif ($_.type -eq 'Important') {
      Write-Important $_.message -replay
    }
    elseif ($_.type -eq 'Execute') {
      write-execute $_.command $_.message -replay
    }
  }
}

Set-Alias ss Show-Steps
Export-ModuleMember Write-SubStep, Write-Important, Show-Steps -Alias ss

# get all colors:
# [enum]::GetValues([System.ConsoleColor]) | Foreach-Object {Write-Host "Command's Executed Steps, $_" -ForegroundColor blue -backgroundColor $_ }