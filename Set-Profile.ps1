
if (Test-Path $profile.CurrentUserAllHosts) {
  "profile already exist: $($profile.CurrentUserAllHosts)"
  "append current profile..."
} else {
  "create new profile: $($profile.CurrentUserAllHosts)"
  New-Item -ItemType File -Path $profile.CurrentUserAllHosts -Force
}
Add-Content -Path $profile.CurrentUserAllHosts -Value ". $PSScriptRoot\profile.ps1"
'profile setup done!'

