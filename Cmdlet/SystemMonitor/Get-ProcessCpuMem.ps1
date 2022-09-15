# https://powershell.one/tricks/performance/performance-counters
# https://superuser.com/questions/1314534/windows-powershell-displaying-cpu-percentage-and-memory-usage
$cores = (get-CimInstance Win32_Processor).NumberOfLogicalProcessors

get-CimInstance -class Win32_PerfFormattedData_PerfProc_Process |
Where-Object {$_.Name -notmatch "^(idle|_total|system)$" -and $_.PercentProcessorTime -gt 0} |
select-object -property @{Name = "CPU(%)"; Expression = {([Math]::Round($_.PercentProcessorTime/$cores, 3))}}, @{Name = "PID"; Expression = {$_.IDProcess}}, @{"Name" = "Memory(MB)"; Expression = {[int]($_.WorkingSetPrivate/1mb)}}, Name |
Sort-Object -Property 'CPU(%)' -Descending
    # Select-Object -First 15

# show-updatingTable.ps1 {Get-ProcessCpuMem.ps1}
# could modify this file and continue running above command