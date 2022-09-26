[CmdletBinding()]
param (
  [Parameter()]
  [bool]
  $vm
)

if ($vm) {
  # xbox services
  $XboxServices = @(
    "XblAuthManager"                    # Xbox Live Auth Manager
    "XblGameSave"                       # Xbox Live Game Save
    "XboxGipSvc"                        # Xbox Accessory Management Service
    "XboxNetApiSvc"
  )
  $XboxServices | % { Set-Service $_ -Status Stopped -StartupType Disabled }
  $services = @(
    # 'TabletInputService', # Touch keyboard and Handwriting Panel Service; needed by WT
    'BthAvctpSvc', #stop Bluetooth Audio Video Control Transport Protocol service service
    'DiagTrack' # Connected User Experiences and Telemetry
    'lfsvc' # Geolocation Service
    # 'CertPropSvc' # Certificate Propagation for smart card reader; not work access denied
    # 'mpssvc', # Windows Defender Firewall
    # 'wscsvc' # Windows Security center service
  )

  $services | % { Set-Service $_ -Status Stopped -StartupType Disabled }

  # disable windows definder service
  # this way is also not work, can not modify the value even manully
  # Write-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\wscsvc' -Name 'start' -Value 4 # 2 is default Windows Security center service
  # Write-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend' -Name 'start' -Value 4 # 2 is default
  # https://www.alitajran.com/turn-off-windows-defender-in-windows-10-permanently/

}
else {

}