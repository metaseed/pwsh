'PSReadline', 'PowershellGet', 'Pester', 'Microsoft.PowerShell.ConsoleGuiTools', 'PSFzf', 'posh-git' | % {
  $module = $_
  # write-host "try update module $module" -ForegroundColor Yellow
  $error.Clear()
  "update module $module ..."
  Update-Module $module -ErrorAction Ignore
  if ($error) {
    "   install module $module ..."
    Install-Module $module -force
  }
}
