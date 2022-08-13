
function Write-Step {
  param (
    [string]$message,
    [switch]$replay,
    [switch]$NoSpeak
  )
  $message = [Regex]::Replace($message , '\b.', { $args[0].Value.ToUpper() })
  $step = ++$__Session.step
  if (! $replay) {
    if (! $NoSpeak) { Speak-Text "Step ${step}: $message" }
    WriteStepMsg @{type = 'Step'; message = $message }
  }
  # Write-Progress -Activity  $message -status " " -Id 0
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
    [switch]$replay,
    [switch]$NoSpeak,
    [string]$SpeakMessage
  )

  $subStep = ++$__Session.subStep
  $numberStr =$__Session.Step ? "$($__Session.Step).${subStep}" : "${subStep}"
  if (!$replay) {
    if (!$NoSpeak || $SpeakMessage ) { Speak-Text "Substep ${numberStr}: $($SpeakMessage ?? $message)" }
    WriteStepMsg @{type = 'SubStep'; message = $message }
  }

  # Write-Progress -Activity  $message -status " " -Id 0
  $icon = "SubStep ${numberStr}->>"
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