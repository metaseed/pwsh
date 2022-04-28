function Write-Step($message) {
  # Write-Progress -Activity  $message -status " " -Id 0

  Write-Host $message -BackgroundColor blue -ForegroundColor yellow
}