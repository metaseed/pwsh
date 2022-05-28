function WriteError {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, position = 0)]
    [object]
    $err,
    [switch]$replay
  )
  if (! $replay) {
    WriteStepMsg @{type = 'Error'; message = $err; }
  }
  else {
    Write-Host "ERROR: $err" -ForegroundColor Red
  }
}