# Import-Module Metaseed.Terminal  -DisableNameChecking
if ($env:WT_SESSION) {
  Start-WTCyclicBgImg $PSScriptRoot\settings.json
}