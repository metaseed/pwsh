function Write-Action {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory, Position = 0)]
    [string]$message,
    [Parameter(Position = 1)]
    [switch]$replay = $false,
    [switch]$Speak,
    [string]$SpeakMessage
  )
  $execute = ++$__PSReadLineSessionScope.execute
  $StepInfo = ""
  $StepInfo += ($null -ne $__PSReadLineSessionScope.Step) ? "$($__PSReadLineSessionScope.Step)." : ''
  $StepInfo += ($null -ne $__PSReadLineSessionScope.SubStep) ? "$($__PSReadLineSessionScope.SubStep).": ''
  if (!$replay) {
    if ($Speak || $SpeakMessage) { Speak-Text "Action $StepInfo${execute}: $($SpeakMessage ?? $message)" }
    WriteStepMsg @{type = 'Action'; message = $message; }
  }

  # Write-Progress -Activity "${command}" -status "$('' -eq $message ? ' ': ": $message")" -Id 2 -ParentId 0
  $icon = $env:TERM_NERD_FONT ? '-->': '―→'
  $exeStep = ++$__PSReadLineSessionScope.ExeStep

  $indents = ' ' * (($__PSReadLineSessionScope.indents + 1) * $__IndentLength)

  $allExe = ($null -ne $__PSReadLineSessionScope.Step) -or ($null -ne $__PSReadLineSessionScope.SubStep) ? "($($exeStep))": ''
  $ic = $env:TERM_NERD_FONT ? '🚀' : ''
  Write-Host "${indents}▐${ic}Action $StepInfo$execute$allExe$icon $message" -ForegroundColor Blue
}