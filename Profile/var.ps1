# leak into (varriable:)
# variable or gci variable
$m = [PSCustomObject]@{
  pwsh = "$env:MS_PWSH"
  metatool = 'M:\Workspace\metatool'
}

# prevent error when debugging
$global:__PSReadLineSessionScope = @{}

$4 = [PSCustomObject]@{
  tm = $env:TEMP # transient temp
  tmp = 'c:\tmp' # short temp
  temp = 'c:\temp' # long temp
}