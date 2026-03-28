# time is spent on import the module 0.3s
# Import-Module Metaseed.Terminal  -DisableNameChecking
if ($env:WT_SESSION) {
  # deferred to background to reduce profile load time (~0.3s saved)
  # use [powershell]::Create() instead of Start-ThreadJob to avoid ~48ms ThreadJob module init
  $__wtSettingsPath = "$PSScriptRoot\settings.json"
  $__ps = [powershell]::Create().AddScript({ param($p); Start-WTCyclicBgImg $p }).AddArgument($__wtSettingsPath)
  $null = $__ps.BeginInvoke()
}
# if ($env:WT_SESSION) {
#   # Register-EngineEvent -SourceIdentifier 'PWSH_PROFILE_LOADED_EVENT' {
#     # $line = $event.SourceArgs.line
#     write-host "$PSScriptRoot\settings.json"
#     Start-WTCyclicBgImg $PSScriptRoot\settings.json
#   # }
# }
# if ($env:WT_SESSION) {
#   Start-WTCyclicBgImg $PSScriptRoot\settings.json
# }