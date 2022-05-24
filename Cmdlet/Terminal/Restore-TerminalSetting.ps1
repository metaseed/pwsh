
[CmdletBinding()]
param (
  [Parameter()]
  [ValidateSet('Stable', 'Preview', 'Unpackaged')]
  [string]
  $version =""
)
. $PSScriptRoot/private/GetSettings.ps1

$backup = "$env:MS_PWSH\Cmdlet\Terminal\settings.json"
if(! (test-path $backup)) {
  Write-Warning 'Backup file not found.'
  return;
}

if ($version -eq '') {
  $installs = GetSettings
  if ($installs.Keys.Count -eq 0) {
    Write-Host "No terminal settings found."
    return
  }
  elseif ($installs.Keys.Count -gt 1) {
    Write-Host "Multiple installs found. Please specify one of the following:"
    $installs | % {
      Write-Host "$($_.name): $($_.value)"
    }
    $decision = $Host.UI.PromptForChoice('Selection', 'select version to backup', ($installs.keys | % { "&$_" }), 0)
    $version = ($installs.GetEnumerator())[$decision].name
  }
  else {
    # only one install found
    $version = ($installs.GetEnumerator())[0].name
  }
}

$location = $installs[$version]
if (test-path $backup) {
  # Confirm-Continue "Overwrite existing setting.json for the WindowsTerminal $version version?"
  if ((gi $location).LastWriteTime -gt (gi $backup).LastWriteTime) {
    $decision = $Host.UI.PromptForChoice('Skip Backup?', "installed setting file is newer than the backup setting file. Skipping backup?", @('&Yes', '&No'), 0)
    if ($decision -eq 0) {
      Write-Host "Skipping restore."
      return
    }
  }
  Copy-Item  $backup $location -Force
}
else {
  Write-Error "Could not find $backup, nothing to restore!"
}
