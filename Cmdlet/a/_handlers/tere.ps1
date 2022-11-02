[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $appPath,
  # remaining parameters
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)
$result = & $appPath --no-gap-search --autocd-timeout off @Remaining # --gap-search-anywhere
# Write-Host $result
if ($result) {
  $result |scb
  Set-Location $result
}
