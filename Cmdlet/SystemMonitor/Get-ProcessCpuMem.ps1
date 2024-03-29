# https://powershell.one/tricks/performance/performance-counters
# https://superuser.com/questions/1314534/windows-powershell-displaying-cpu-percentage-and-memory-usage

[CmdletBinding()]
param (
  [Parameter()]
  [int]
  $cores = 0
)
# write-host $cores
if ($cores -eq 0) {
  $cores = (get-CimInstance Win32_Processor).NumberOfLogicalProcessors
}
# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\PerfProc\Performance
# Disable Performance Counters need to set to 0, otherwise Invalid Class ( “exctrlst.exe” tool, enabled ‘perfproc’ and rebooted.)
# https://thwack.solarwinds.com/products/server-application-monitor-sam/f/forum/62618/win32_perfrawdata_perfproc_process---invalid-class
get-CimInstance -class Win32_PerfFormattedData_PerfProc_Process |
Where-Object { $_.Name -notmatch "^(_total|system)$" } | #idle -and $_.PercentProcessorTime -gt 0
select-object -property @{Name = 'ParentId'; Expression = { $_.CreatingProcessID } },
@{Name = 'Threads'; Expression = { $_.ThreadCount } },
@{Name = "PID"; Expression = { $_.IDProcess } },
@{Name = "Memory(MB)"; Expression = { [int]($_.WorkingSetPrivate / 1mb) } },
@{Name = "CPU(%)"; Expression = { ([Math]::Round($_.PercentProcessorTime / $cores, 3)) } },
Name |
Sort-Object -Property 'CPU(%)' -Descending
# Select-Object -First 15

# wct {Get-ProcessCpuMem.ps1}
# could modify this file and continue running above command