$processor = Get-CimInstance -class win32_processor -Property numberOfCores, NumberOfLogicalProcessors
# $Cores = $processor.numberOfCores
$LogicalProcessors = $processor.NumberOfLogicalProcessors

(get-counter '\Process(*)\% Processor Time' -ErrorAction Ignore) |
select -ExpandProperty CounterSamples |
Sort-Object -Property CookedValue -Descending |
? {
  $_.InstanceName -ne '_total'  -and $_.InstanceName -ne 'idle' # -and $_.CookedValue -gt 0
} |
select   @{Name = 'CPU(%)'; Expression = { "$([Math]::Round($_.CookedValue / $LogicalProcessors, 3))" } }, InstanceName

# show-updatingTable.ps1 {Get-ProcessCpu.ps1}
# you could always modify this file during the above script running, and get modified result
# (Get-Counter -ListSet process).Paths