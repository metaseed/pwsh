function Write-Action {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory, Position = 0)]
    [string]$message,
    [Parameter(Position = 1)]
    [switch]$replay = $false
  )
  if (! $replay) {
    WriteStepMsg @{type = 'Action'; message = $message; }
  }

  # Write-Progress -Activity "${command}" -status "$('' -eq $message ? ' ': ": $message")" -Id 2 -ParentId 0
  $icon = $env:WT_SESSION ? '-->': '―→'
  $execute = ++$__Session.execute
  $exeStep = ++$__Session.ExeStep

  $indents = ' ' * (($__Session.indents + 1) * $__IndentLength)
  $StepInfo = ""
  $StepInfo += ($null -ne $__Session.Step) ? "$($__Session.Step)." : ''
  $StepInfo += ($null -ne $__Session.SubStep) ? "$($__Session.SubStep).": ''
  $allExe = ($null -ne $__Session.Step) -or ($null -ne $__Session.SubStep) ? "($($exeStep))": ''
  Write-Host "${indents}:Action $StepInfo$execute$allExe$icon $message" -ForegroundColor Blue
}