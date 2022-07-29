[CmdletBinding()]
param (
  [Parameter()]
  [bool]
  $vm
)

if($vm) {

} else {

}

write-action 'Disable Connected User Experiences and Telemetry'
# https://www.windowscentral.com/how-opt-out-customer-experience-improvement-program-windows-10
# http://www.kjrnet.com/Info/Windows%207%20Hidden%20Settings%202.html

$tasks = @('StartupAppTask',
  'Microsoft Compatibility Appraiser', 'ProgramDataUpdater', 'PcaPatchDbTask', # Applicaton Experience
  'Consolidator', 'UsbCeip', # Customer Experience Improvement Program
  'Microsoft-Windows-DiskDiagnosticDataCollector', 'Microsoft-Windows-DiskDiagnosticResolver' # DiskDiagnostic
)
$tasks | Disable-SchTask

# disable Tasks
Get-ScheduledTask *google* | Disable-ScheduledTask
Get-ScheduledTask *MicrosoftEdge* | Disable-ScheduledTask
Get-ScheduledTask *OneDrive* | Disable-ScheduledTask