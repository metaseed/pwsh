
[CmdletBinding()]
param (
  [Parameter(Mandatory=$true, Position=0)]
  [ValidateSet('Stable', 'Preview', 'Unpackaged')]
  [string[]]
  $version
)

# https://docs.microsoft.com/en-us/windows/terminal/install#settings-json-file
$Settings = @{
  Stable     = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
  Preview    = "$env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
  Unpackaged = "$env:LocalAppData\Microsoft\Windows Terminal\settings.json" # Scoop, Chocolately, etc)
}

$backup = "M:/Script/Terminal/settings.json"
$location = $Settings[$version]
if (test-path $location) {
  Write-Step "Found $($location.Value), backing up to $backup"
  Copy-Item $location $backup -Force
}
else {
  Write-Error "Could not find $($location.Value), nothing to backup!"
}
