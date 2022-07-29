[CmdletBinding()]
param (
  [Parameter()]
  [bool]
  $vm
)

if ($vm) {
  $XboxServices = @(
    "XblAuthManager"                    # Xbox Live Auth Manager
    "XblGameSave"                       # Xbox Live Game Save
    "XboxGipSvc"                        # Xbox Accessory Management Service
    "XboxNetApiSvc"
  )
  $XboxServices | % { Get-ScheduledTask $_ } | Disable-ScheduledTask

  $services = @(
    # needed by WT 'TabletInputService', # Touch keyboard and Handwriting Panel Service
    'BthAvctpSvc', #stop Bluetooth Audio Video Control Transport Protocol service service
    'DiagTrack' # Connected User Experiences and Telemetry
    'lfsvc' # Geolocation Service
    # not work access denied'CertPropSvc' # Certificate Propagation for smart card reader
    # 'mpssvc', # Windows Defender Firewall
    # 'wscsvc' # Windows Security center service
  )

  $services | % { Set-Service $_ -Status Stopped -StartupType Disabled }


  # disable windows definder service 
  # this way is also not work, can not modify the value even manully
  # Write-ItemPropertyHKLM:\SYSTEM\CurrentControlSet\Services\wscsvc' -Name 'start' -Value 4 # 2 is default Windows Security center service
  # Write-ItemPropertyHKLM:\SYSTEM\CurrentControlSet\Services\WinDefend' -Name 'start' -Value 4 # 2 is default
  # https://www.alitajran.com/turn-off-windows-defender-in-windows-10-permanently/

}
else {
  
}