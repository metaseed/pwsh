
if (!(Test-Path $profile.CurrentUserAllHosts)) {
  New-Item -ItemType File -Path $profile.CurrentUserAllHosts -Force
  Add-Content -Path $profile.CurrentUserAllHosts -Value ". $PSScriptRoot\profile.ps1"
  Write-Host 'profile setup done!'
  return
}
Write-Host "profile already exist: $($profile.CurrentUserAllHosts)"
