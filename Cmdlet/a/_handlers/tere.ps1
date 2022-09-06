[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $file,
  # remaining parameters
  [Parameter()]
  $remaining
)
$result = & $file --gap-search-anywhere @Remaining
# Write-Host $result
if ($result) {
  $result |scb
  Set-Location $result
}
