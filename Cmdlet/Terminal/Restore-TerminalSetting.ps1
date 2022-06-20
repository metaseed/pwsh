
[CmdletBinding()]
param (
  [Parameter()]
  [ValidateSet('Stable', 'Preview', 'Unpackaged')]
  [string]
  $version =""
)
Write-Action "restore windows terminal settings..."
. $PSScriptRoot/_private/GetSettings.ps1

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
    $installs.GetEnumerator() | % {
      Write-Host "$($_.name): $($_.value)"
    }
    $decision = $Host.UI.PromptForChoice('Selection', 'select version to backup', ($installs.keys | % { "&$_" }), 0)
    $version = ($installs.GetEnumerator())[$decision].name
  }
  else {
    # only one install found
    $installs.GetEnumerator() | % {
      Write-Host "$($_.name): $($_.value)"
    }
    $ins = ($installs.GetEnumerator())[0]
    $version = $ins.name
  }
}

$location = $installs[$version]
if (test-path $backup) {
  # Confirm-Continue "Overwrite existing setting.json for the WindowsTerminal $version version?"
  if ((gi $location).LastWriteTime -gt (gi $backup).LastWriteTime) {
    $decision = $Host.UI.PromptForChoice('Skip Restore?', "installed setting file is newer than the backuped setting file. Skipping restore?", @('&Yes', '&No'), 1)
    if ($decision -eq 0) {
      Write-Host "Skipping restore."
      return
    }
  }
  write-execute {Copy-Item  $backup $location -Force}#.GetNewClosure()
}
else {
  Write-Error "Could not find $backup, nothing to restore!"
}
