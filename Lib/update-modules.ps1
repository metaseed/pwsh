'PSReadline', 'PowershellGet', 'Pester', 'Microsoft.PowerShell.ConsoleGuiTools' | % {
  $module = $_
  # write-host "try update module $module" -ForegroundColor Yellow
  $error.Clear()
  "update module $module ..."
  Update-Module $module -ErrorAction SilentlyContinue
  if ($error) {
    "   install module $module ..."
    Install-Module $module -force
  }
}
