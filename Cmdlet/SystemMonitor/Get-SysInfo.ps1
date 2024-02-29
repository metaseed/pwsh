# this way may generate error: on some system that not enable this counter:
# Get-Counter: The specified object was not found on the computer.
#
# # $availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
# $usedMem = (((Get-Ciminstance Win32_OperatingSystem).TotalVisibleMemorySize * 1kb) - ((Get-Counter -Counter "\Memory\Available Bytes").CounterSamples.CookedValue)) / 1Mb
# $memPer = (104857600 * $usedMem / $totalRam).ToString("#,0.0").PadLeft(3) + '%'
# $mem = "Mem: `e[32m$memPer`e[0m($(($usedMem / 1KB).ToString("#,0.0"))GB)" #  "Mem: $memPer ($(($usedMem / 1KB).ToString("#,0.0"))GB"
# write-host $mem

# add dll from assembly cache
add-type -AssemblyName 'Microsoft.VisualBasic'
$info = [Microsoft.VisualBasic.Devices.ComputerInfo]::new()
Add-Member -InputObject $info -NotePropertyMembers @{
	TotalPhysicalMemoryInGb=($info.TotalPhysicalMemory / 1Gb).ToString("#,0.0Gb")
	AvailablePhysicalMemoryInGb = ($info.AvailablePhysicalMemory / 1Gb).ToString("#,0.0Gb")
	AvailablePercent = ($info.AvailablePhysicalMemory / $info.TotalPhysicalMemory ).ToString("#,0.0%")
 }
$info