[CmdletBinding()]
param (
  [Parameter()]
  [switch]
  $all
)

Get-CimInstance Win32_LogicalDisk |
# 3: fixed disk, 2: removable disk
Where-Object {
  if ($all) { return $true } else { $_.DriveType -eq "3" }
} |
Select-Object -Property SystemName, # DESKTOP-AQG88L0
@{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } },
VolumeName, # System, Data
@{ Name = "Size (GB)" ; Expression = { "{0:N1}" -f ( $_.Size / 1gb) } },
@{ Name = "FreeSpace (GB)" ; Expression = { "{0:N1}" -f ( $_.Freespace / 1gb ) } },
@{ Name = "PercentFree" ; Expression = {
  $percent = $_.FreeSpace / $_.Size
  $blocks = [Math]::Round($percent * 10)
  $blocksUsed =  "$([char]9632)" * $blocks
  $blocksFree =  "$([char]9632)" * (10 - $blocks)
  $progressBarUsed = Get-AnsiText $blocksUsed -ForegroundColor ($percent -gt 0.85 ? 'Red' : 'LightGreen')
  $progressBarFree = Get-AnsiText $blocksFree -ForegroundColor DarkGray
  $output = ("{0:P1}" -f $percent ).PadLeft(5, ' ')
  return "$output $progressBarUsed$progressBarFree"
}
} |
Format-Table -AutoSize
# |
# Out-String