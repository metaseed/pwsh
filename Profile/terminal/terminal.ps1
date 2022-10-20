# time is spent on import the module 0.3s
# Import-Module Metaseed.Terminal  -DisableNameChecking
if ($env:WT_SESSION) {
  # use timer to reduce the profile loading timer about 0.3s
  $timer = [Timers.Timer]::new(2000)
  $timer.AutoReset =$false
  $null = Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {
    # write-host "$PSScriptRoot\settings.json"
    Start-WTCyclicBgImg $PSScriptRoot\settings.json
    $timer.Dispose()
  }
  $timer.start()
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