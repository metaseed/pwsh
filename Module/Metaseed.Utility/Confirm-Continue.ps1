function Enter-Continue([string] $mesage) {
  Write-Host "`n$message`npress 'Enter' to continue, 'Any key' to cancel...`n" -ForegroundColor blue
  $key = [Console]::ReadKey().Key
  if ($key -ne [ConsoleKey]::Enter) {
      exit
      return
  }
}