# leak into (varriable:)
# variable or gci variable
$m = @{
  pwsh = "$env:MS_PWSH"
  metatool = 'M:\Workspace\metatool'
}
# previent error when debuging
$global:__Session = @{}