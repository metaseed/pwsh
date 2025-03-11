# leak into (varriable:)
# variable or gci variable
$m = @{
  pwsh = "$env:MS_PWSH"
  metatool = 'M:\Workspace\metatool'
}
# prevent error when debugging
$global:__PSReadLineSessionScope = @{}