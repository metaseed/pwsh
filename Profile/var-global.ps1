# leak into (varriable:)
# variable or gci variable
$m = [PSCustomObject]@{
  pwsh = "$env:MS_PWSH"
  metatool = 'M:\Workspace\metatool'
}

# prevent error when debugging
$global:__PSReadLineSessionScope = @{}

## my typing-shortcut-vars
# 4 is easier to type after typed $
$4 = [PSCustomObject]@{
  tm = $env:TEMP # transient temp
  tmp = 'c:\tmp' # short temp
  temp = 'c:\temp' # long temp
}