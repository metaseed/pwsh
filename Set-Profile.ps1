if (!(Test-Path -Path $profile.CurrentUserAllHosts)) {
  New-Item -ItemType File -Path $profile.CurrentUserAllHosts -Force
  Add-Content -Path $profile.CurrentUserAllHosts -Value '. m:\script\pwsh\profile.ps1'
  Write-Host 'profile setup'
  return
}
$p = $profile.CurrentUserAllHosts
Write-Host "profile already exist: $p"
