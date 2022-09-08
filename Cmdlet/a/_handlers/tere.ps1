[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $appPath,
  # remaining parameters
  [Parameter()]
  $remaining
)
$result = & $appPath --gap-search-anywhere  --autocd-timeout off @Remaining
# Write-Host $result
if ($result) {
  $result |scb
  Set-Location $result
}
