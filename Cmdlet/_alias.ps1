#Here, Set-Alias is better than New-Alias, because if there is already one with same name, it would not throw but replace it
Set-Alias cpu Show-CpuUsage
Set-Alias bumpVer Update-InfoVersion
Set-Alias sandbox Open-Sandbox
function __change_directory{
  # so d --help work
  a tere -- @args
}
# it is for ls+cd (gci+sl)
# `scb (tere)` will copy the directory to clipboard
Set-Alias d __change_directory