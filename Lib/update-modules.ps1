'PSReadline', 'PowershellGet', 'Pester', 'Microsoft.PowerShell.ConsoleGuiTools' | % {
  $module = $_
  # write-host "try update module $module" -ForegroundColor Yellow
  $error.Clear()
  Update-Module $module -ErrorAction SilentlyContinue
  if ($error) {
      Install-Module $module -force
  }
}
