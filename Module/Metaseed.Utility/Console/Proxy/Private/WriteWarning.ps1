function WriteWarning {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, position = 0)]
    [object]
    $warning,
    [switch]$replay
  )
  if (! $replay) {
    WriteStepMsg @{type = 'Warning'; message = $warning; }
  }
  else {
    Write-Host "Warning: $warning" -ForegroundColor Yellow
  }
}