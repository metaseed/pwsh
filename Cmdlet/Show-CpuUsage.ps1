[CmdletBinding()]
param (
    [Parameter()]
    [int]
    $Count = 8
)

$Cores = (Get-CimInstance -class win32_processor -Property numberOfCores).numberOfCores;

$LogicalProcessors = (Get-CimInstance –class Win32_processor -Property NumberOfLogicalProcessors).NumberOfLogicalProcessors;
$TotalMemory = (get-ciminstance -class "cim_physicalmemory" | % { $_.Capacity })


$DATA = get-process -IncludeUserName |
sort CPU -Descending|
select -First $Count ProcessName, ID, CPU,
@{Name       = 'CPU_Usage'; 
  Expression = { 
    $TotalSec = (New-TimeSpan -Start $_.StartTime).TotalSeconds
    [Math]::Round( ($_.CPU * 100 / $TotalSec) / $LogicalProcessors, 2)
  }
}, 
Handles, WorkingSet, PeakPagedMemorySize, PrivateMemorySize, VirtualMemorySize, UserName, Path, StartTime

$DATA |Format-Table -AutoSize


# $totalRam = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum
# while($true) {
#     $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
#     $cpuTime = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
#     $availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
#     $date + ' > CPU: ' + $cpuTime.ToString("#,0.000") + '%, Avail. Mem.: ' + $availMem.ToString("N0") + 'MB (' + (104857600 * $availMem / $totalRam).ToString("#,0.0") + '%)'
#     Start-Sleep -s 2
# }