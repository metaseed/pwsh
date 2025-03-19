[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $appPath,
  # remaining parameters
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

$setLocation = $Remaining -contains '-setLocation'
if($setLocation) {
  $remaining.remove('-setLocation')
}
# $setLocation
$result = & $appPath --normal-search --autocd-timeout off @Remaining # --gap-search-anywhere

# Write-Host $result
if ($result) {
  $result |scb
  if($setLocation) {
    Set-Location $result
  } else {
    $result
  }
}
# debug
 #D