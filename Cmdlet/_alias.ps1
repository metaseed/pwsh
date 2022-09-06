#Here, Set-Alias is better than New-Alias, because if there is already one with same name, it would not throw but replace it
Set-Alias weather Show-Weather
Set-Alias cpu Show-CpuUsage
Set-Alias space Show-DiskSpace
Set-Alias bumpVer Update-InfoVersion
Set-Alias sandbox Open-Sandbox
function __change_directory{
  # so d --help work
  a tere -- @args
}
# it is for ls+cd (gci+sl)
Set-Alias d __change_directory