Get-CimInstance Win32_LogicalDisk |
# 3: fixed disk, 2: removable disk
Where-Object { $_.DriveType -eq "3" } |
Select-Object SystemName,
@{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } },
VolumeName,
@{ Name = "Size (GB)" ; Expression = { "{0:N1}" -f ( $_.Size / 1gb) } },
@{ Name = "FreeSpace (GB)" ; Expression = { "{0:N1}" -f ( $_.Freespace / 1gb ) } },
@{ Name = "PercentFree" ; Expression = { "{0:P1}" -f ( $_.FreeSpace / $_.Size ) } } |
Format-Table -AutoSize|
Out-String