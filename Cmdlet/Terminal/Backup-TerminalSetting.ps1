
[CmdletBinding()]
param (
  [ValidateSet('Stable', 'Preview', 'Unpackaged')]
  [string]
  $version = ''
)
  
. $PSScriptRoot/private/GetSettings.ps1
if ($version -eq '') {
  $installs = GetSettings
  if ( $installs.keys.count -eq 0 ) {
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
    $version = ($installs.GetEnumerator())[0].name
  }
}
$backup = "$env:MS_PWSH\Cmdlet\Terminal\settings.json"
$location = $installs[$version]
if (test-path $location) {
  Write-Step "Found $($location), backing up to $backup"
  if (-not (test-path $backup)) {
    New-Item -ItemType File -Path $backup -Force | out-null
  }
  if ((gi $location).LastWriteTime -lt (gi $backup).LastWriteTime) {
    $decision = $Host.UI.PromptForChoice('Skip Backup?', "Backup setting file is newer than the installed setting file. Skipping backup?", @('&Yes', '&No'), 0)
    if ($decision -eq 0) {
      Write-Host "Skipping backup"
      return
    }
  }
  Copy-Item -Path $location -Destination $backup -Force

}
else {
  Write-Error "Could not find $($location.Value), nothing to backup!"
}
