[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $appPath,
  # remaining parameters
  [Parameter()]
  $remaining
)
$result = & $appPath --gap-search-anywhere @Remaining
# Write-Host $result
if ($result) {
  $result |scb
  Set-Location $result
}
