
function Write-Step {
  param (
    [string]$message,
    [switch]$replay,
    [switch]$NoSpeak,
    [string]$SpeakMessage
  )
  $message = [Regex]::Replace($message , '\b.', { $args[0].Value.ToUpper() })
  $step = ++$__PSReadLineSessionScope.step
  if (! $replay) {
    if (!$NoSpeak || $SpeakMessage) { Speak-Text "Step ${step}: $($SpeakMessage ?? $message)" }
    WriteStepMsg @{type = 'Step'; message = $message }
  }
  # Write-Progress -Activity  $message -status " " -Id 0
  $__PSReadLineSessionScope.subStep = $null
  $__PSReadLineSessionScope.execute = 0
  $__PSReadLineSessionScope.indents = 0
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

  $subStep = ++$__PSReadLineSessionScope.subStep
  $numberStr =$__PSReadLineSessionScope.Step ? "$($__PSReadLineSessionScope.Step).${subStep}" : "${subStep}"
  if (!$replay) {
    if (!$NoSpeak || $SpeakMessage ) { Speak-Text "Substep ${numberStr}: $($SpeakMessage ?? $message)" }
    WriteStepMsg @{type = 'SubStep'; message = $message }
  }

  # Write-Progress -Activity  $message -status " " -Id 0
  $icon = "SubStep ${numberStr}->>"
  $__PSReadLineSessionScope.indents = 1
  $__PSReadLineSessionScope.execute = 0

  $indents = ' ' * $__IndentLength
  Write-host "$indents" -NoNewline
  Write-Host "▐" -ForegroundColor Blue  -NoNewline
  Write-Host "$icon $message" -ForegroundColor Green -BackgroundColor White -NoNewline
  Write-Host ""
}

Export-ModuleMember Write-SubStep 

# get all colors:
# [enum]::GetValues([System.ConsoleColor]) | Foreach-Object {Write-Host "Command's Executed Steps, $_" -ForegroundColor blue -backgroundColor $_ }