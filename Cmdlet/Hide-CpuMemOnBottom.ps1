[CmdletBinding()]
param (
)

$env:__ShowCpuMemOnBtm= $false
$x = [Console]::CursorLeft
$y = [Console]::CursorTop

[Console]::CursorTop = [Console]::WindowTop + [Console]::WindowHeight - 1
[Console]::Write("`e[2K") # clear current line (bottom line)
[Console]::SetCursorPosition($x, $y)