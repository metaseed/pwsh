Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
'PSReadline', 'PowershellGet', 'Pester', 'Microsoft.PowerShell.ConsoleGuiTools',
 'PSEverything', # used by psfzf Set-LocationFuzzyEverything
 'PSFzf', 'posh-git' | % {
  $module = $_
  # write-host "try update module $module" -ForegroundColor Yellow
  $error.Clear()
  "update module $module ..."
  Update-Module $module -ErrorAction Ignore
  if ($error) {
    "   install module $module ..."
    Install-Module $module -force
  } else {
    "module $module updated successfully!"
  }
}
