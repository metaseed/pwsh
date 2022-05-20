
[CmdletBinding()]
param (
  [Parameter()]
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
if (test-path $backup) {
  Confirm-Continue "Overwrite existing setting.json for the WindowsTerminal $version version?"
  Copy-Item  $backup $location -Force
}
else {
  Write-Error "Could not find $backup, nothing to restore!"
}
