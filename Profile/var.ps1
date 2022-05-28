# leak into (varriable:)
# variable or gci variable
$m = @{
  pwsh = "$env:MS_PWSH"
}
# previent error when debuging
$global:__Session = @{}