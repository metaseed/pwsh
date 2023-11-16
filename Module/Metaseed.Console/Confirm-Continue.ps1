<# for choices:

$choiceIndex = $Host.UI.PromptForChoice('title', 'Are you sure you want to proceed?', @('&Yes', '&No'), 1)
if ($choiceIndex -eq 0) {
    Write-Host 'confirmed'
} else {
    Write-Host 'cancelled'
}
#>
function Confirm-Continue {
  [CmdletBinding()]
  param(
    [string] $message,
    [System.ConsoleKey]$ConfirmKey = [ConsoleKey]::Enter,
    # return user selection: $true for confirm, $false for break
    [switch] $Result
  )
  Beep-DingDong
  Write-Attention "$message"
  Write-Host "Press'$ConfirmKey' to continue, 'any other key' to break script excution..." -ForegroundColor Yellow
  $key = [Console]::ReadKey().Key

  if ($key -ne $ConfirmKey ) {
    Write-Host "`nScript excution broken!"
    if ($Result) {
      return $false
    }
    else {
      break SCRIPT
    }
  }
  Write-Host "`nContinuing script excution..."
  if ($Result) {
    return $true
  }
}
