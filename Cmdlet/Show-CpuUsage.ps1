[CmdletBinding()]
param (
  [Parameter()]
  [int]
  $Count = 8,
  # process id
  [Parameter()]
  [int]
  $ProcessId,
  # Since Start
  [Parameter()]
  [switch]
  $SinceStart

)

$Cores = (Get-CimInstance -class win32_processor -Property numberOfCores).numberOfCores;
$LogicalProcessors = (Get-CimInstance –class Win32_processor -Property NumberOfLogicalProcessors).NumberOfLogicalProcessors;
Write-Host "Cores: $Cores, LogicalProcessors: $LogicalProcessors"
$TotalMemory = (get-ciminstance -class "cim_physicalmemory" | % { $_.Capacity })


if ($SinceStart) {
  $DATA = get-process -IncludeUserName |
  sort CPU -Descending |
  select -First $Count ProcessName, ID, CPU,
  @{Name       = 'CPU_Usage'; 
    Expression = { 
      $TotalSec = (New-TimeSpan -Start $_.StartTime).TotalSeconds
      "$([Math]::Round( ($_.CPU * 100 / $TotalSec) / $LogicalProcessors, 4) * 100)%"
    }
  }, StartTime,
  Handles, WorkingSet, VirtualMemorySize, PeakPagedMemorySize, PrivateMemorySize, UserName, Path

  $DATA | Format-Table -AutoSize
}
else {
  if ($ProcessId) {
  
    # This is to find the exact counter path, as you might have multiple processes with the same name
    $proc_path = ((Get-Counter "\Process(*)\ID Process").CounterSamples | ? { $_.RawValue -eq $ProcessId }).Path
    # We now get the CPU percentage
    $prod_percentage_cpu = [Math]::Round(((Get-Counter ($proc_path -replace "\\id process$", "\% Processor Time")).CounterSamples.CookedValue) / $LogicalProcessors, 3)
    "$prod_percentage_cpu%"
  }
  else {
    get-counter '\Process(*)\% Processor Time' |
    select -ExpandProperty CounterSamples |
    Sort-Object -Property CookedValue -Descending |
    ? { $_.InstanceName -ne '_total' -and $_.InstanceName -ne 'idle' } |
    select  InstanceName, @{Name = 'CPU'; Expression = { "$([Math]::Round($_.CookedValue / $LogicalProcessors, 3))%" } } -First $Count
  }

}

# $totalRam = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum
# while($true) {
#     $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
#     $cpuTime = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
#     $availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
#     $date + ' > CPU: ' + $cpuTime.ToString("#,0.000") + '%, Avail. Mem.: ' + $availMem.ToString("N0") + 'MB (' + (104857600 * $availMem / $totalRam).ToString("#,0.0") + '%)'
#     Start-Sleep -s 2
# }

# Get-CimInstance win32_processor | Measure-Object -Property LoadPercentage -Average
# https://www.techtarget.com/searchenterprisedesktop/tip/How-IT-admins-can-use-PowerShell-to-monitor-CPU-usage
