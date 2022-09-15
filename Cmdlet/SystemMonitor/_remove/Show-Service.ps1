[CmdletBinding()]
param (
  [Parameter()]
  [string[]]
  $Services
)
# Write-Output "`e[3S$text`e[3T"
# $HOST.UI.RawUI.ScrollBufferContents(
[Console]::CursorVisible = $false
# scroll to top to give more space for display
[Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen() #ctrl-l
# in window terminal the position is only relative to the window, not to the whole buffer, 
# so if the content can not be showed in a window, not work as expected: only override part of the last output
$StartPosition =  $HOST.UI.RawUI.CursorPosition 
Write-Host ""
# move cursor to the start of the command line
$StartPosition.X = 0
# $StartPosition.Y += $HOST.UI.RawUI.WindowPosition.Y
# Write-Output "`e7" # save cursor host
# $p = [Console]::GetCursorPosition()
$i = 0
while ($true) {
  # Write-Host "`e[H"
  # Write-Host "`e[0J" -NoNewline #clear screen after cursor
  
  $a = gsv $Services | Format-Table -AutoSize | Out-String
  if (!$a) {
    write-host "`nno service found!"
    return
  }

  $i++
  #2K clear current line
  Write-Host "`e[2Kupdates: ${i}s"
  # `e0J clear screen after cursor
  Write-Host "`e[0J$a" -NoNewline
  [Console]::CursorVisible = $false

  # $HOST.UI.RawUI.CursorPosition
  sleep -Milliseconds 1000
  # Write-Host ("`b" * $a.Length)
  $end = $HOST.UI.RawUI.CursorPosition
  $HOST.UI.RawUI.CursorPosition = $StartPosition
  # "`e8" #godo saved positon
  # [System.Console]::SetCursorPosition($p.Item1, $p.Item2)
}

$HOST.UI.RawUI.CursorPosition = $end
[Console]::CursorVisible = $true
