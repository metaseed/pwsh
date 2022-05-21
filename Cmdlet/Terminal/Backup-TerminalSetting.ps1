
[CmdletBinding()]
param (
  [ValidateSet('Stable', 'Preview', 'Unpackaged')]
  [string]
  $version = ''
)

# https://docs.microsoft.com/en-us/windows/terminal/install#settings-json-file
$Settings = @{
  Stable     = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
  Preview    = "$env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
  Unpackaged = "$env:LocalAppData\Microsoft\Windows Terminal\settings.json" # Scoop, Chocolately, etc)
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
$backup = "$env:MS_PWSH\Cmdlet\Terminal\settings.json"
$location = $Settings[$version]
if (test-path $location) {
  Write-Step "Found $($location), backing up to $backup"
  if (-not (test-path $backup)) {
    New-Item -ItemType File -Path $backup -Force |out-null
  }
  Copy-Item $location $backup -Force
}
else {
  Write-Error "Could not find $($location.Value), nothing to backup!"
}
