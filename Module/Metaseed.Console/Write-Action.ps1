function Write-Action {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory, Position = 0)]
    [string]$message,
    [Parameter(Position = 1)]
    [switch]$replay = $false,
    [switch]$NoSpeak
  )
  $execute = ++$__Session.execute
  $StepInfo = ""
  $StepInfo += ($null -ne $__Session.Step) ? "$($__Session.Step)." : ''
  $StepInfo += ($null -ne $__Session.SubStep) ? "$($__Session.SubStep).": ''
  if (! $replay) {
    if (! $NoSpeak) { Speak-Text "Action $StepInfo${execute}: $message" }
    WriteStepMsg @{type = 'Action'; message = $message; }
  }

  # Write-Progress -Activity "${command}" -status "$('' -eq $message ? ' ': ": $message")" -Id 2 -ParentId 0
  $icon = $env:WT_SESSION ? '-->': '―→'
  $exeStep = ++$__Session.ExeStep

  $indents = ' ' * (($__Session.indents + 1) * $__IndentLength)

  $allExe = ($null -ne $__Session.Step) -or ($null -ne $__Session.SubStep) ? "($($exeStep))": ''
  $ic = $env:WT_SESSION ? '🚀' : ''
  Write-Host "${indents}▐${ic}Action $StepInfo$execute$allExe$icon $message" -ForegroundColor Blue
}