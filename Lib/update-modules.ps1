Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

'PSReadline', 'PowershellGet', 'Pester', 'Microsoft.PowerShell.ConsoleGuiTools',
 'PSEverything', # used by psfzf Set-LocationFuzzyEverything
 'PSFzf', 'posh-git' | % {
  $module = $_
  $WarningPreferenceBackup = $WarningPreference
  $WarningPreference = 'SilentlyContinue'
  # write-host "try update module $module" -ForegroundColor Yellow
  $error.Clear()
  Write-Verbose "update module $module ..."
  Update-Module $module -ErrorAction Ignore
  if ($error) {
    Write-Verbose "   install module $module ..."
    Install-Module $module -force
  } else {
    Write-Verbose "module $module updated successfully!"
  }
  $WarningPreference = $WarningPreferenceBackup

}
