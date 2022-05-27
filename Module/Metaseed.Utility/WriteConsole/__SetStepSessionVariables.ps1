function __SetStepSessionVariables {
  # https://stackoverflow.com/questions/67136144/getting-powershell-current-line-before-enter-is-pressed
  # cursor is the cursor position in the line, start from 0
  $line = $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $line, [ref] $cursor)
  if ($line -match '^\s*(Show-Steps|ss$)') {
    # if is the Show-Steps command, then not clear the Steps value of the session
    $Steps = $global:__Session.Steps
  }
  else {
    $Steps = @()
  }
  # session scale variable
  $global:__Session.Steps = $Steps

}
