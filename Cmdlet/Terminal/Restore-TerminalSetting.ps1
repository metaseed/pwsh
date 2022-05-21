
[CmdletBinding()]
param (
  [Parameter()]
  [ValidateSet('Stable', 'Preview', 'Unpackaged')]
  [string]
  $version =""
)

# https://docs.microsoft.com/en-us/windows/terminal/install#settings-json-file
$Settings = @{
  Stable     = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
  Preview    = "$env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
  Unpackaged = "$env:LocalAppData\Microsoft\Windows Terminal\settings.json" # Scoop, Chocolately, etc)
}

$backup = "$env:MS_PWSH\Cmdlet\Terminal\settings.json"
if(! (test-path $backup)) {
  Write-Warning 'Backup file not found.'
  return;
}

if ($version -eq '') {
  $installs = $Settings.GetEnumerator() | ? { test-path $_.value }
  if ($null -eq $installs) {
    Write-Host "No terminal settings found."
    return
  }
  elseif ($installs.Count -gt 1) {
    Write-Host "Multiple installs found. Please specify one of the following:"
    $installs | % {
      Write-Host "$($_.key): $($_.value)"
    }
    $decision = $Host.UI.PromptForChoice('Selection', 'select version to backup', ($installs.name | % { "&$_" }), 0)
    $version = $installs[$decision].name
  }
  else {
    # only one install found
    $version = $installs[0].name
  }
}

$location = $Settings[$version]
if (test-path $backup) {
  Confirm-Continue "Overwrite existing setting.json for the WindowsTerminal $version version?"
  Copy-Item  $backup $location -Force
}
else {
  Write-Error "Could not find $backup, nothing to restore!"
}
