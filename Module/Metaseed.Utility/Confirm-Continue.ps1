<# for choices:
$title    = 'something'
$question = 'Are you sure you want to proceed?'
$choices  = '&Yes', '&No'

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
    Write-Host 'confirmed'
} else {
    Write-Host 'cancelled'
}
#>
function Confirm-Continue([string] $mesage) {
  Write-Host "`n$message`npress 'Enter' to continue, 'Any key' to stop...`n" -ForegroundColor blue
  $key = [Console]::ReadKey().Key
  if ($key -ne [ConsoleKey]::Enter) {
    exit
  }
}