<# for choices:

$decision = $Host.UI.PromptForChoice('title', 'Are you sure you want to proceed?', @('&Yes', '&No'), 1)
if ($decision -eq 0) {
    Write-Host 'confirmed'
} else {
    Write-Host 'cancelled'
}
#>
function Confirm-Continue {
  [CmdletBinding()]
  param(
    [string] $message,
    [System.ConsoleKey]$ConfirmKey =  [ConsoleKey]::Enter,
    [switch] $Result
  )
  Write-Attention "$message"
  Write-Host "Press'$ConfirmKey' to Confirm, 'Any key' to $($Result ? 'cancel': 'stop')..." -ForegroundColor Yellow
  Beep-DingDong
  $key = [Console]::ReadKey().Key
  if ($key -ne $ConfirmKey ) {
    Write-Host "`n Stopped!"
    if($Result) { return $false}
    else {break SCRIPT}
  }
  Write-Host "`nContinuing..."
  if($Result) {return $true}
}
# todo: music and background changing