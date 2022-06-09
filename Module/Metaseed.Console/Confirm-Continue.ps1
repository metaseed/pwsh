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
    [string] $message
  )
  Write-Attention "`n$message"
  Write-Host "press'Enter' to continue, 'Any key' to stop...`n" -ForegroundColor blue
  Beep-DingDong
  $key = [Console]::ReadKey().Key
  if ($key -ne [ConsoleKey]::Enter) {
    Write-Host ' stopped!'
    break SCRIPT
  }
  Write-Host "continuing..."
}
# todo: music and background changing