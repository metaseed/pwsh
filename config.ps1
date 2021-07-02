if (Test-Path $profile.CurrentUserAllHosts) {
  "profile.CurrentUserAllHosts already exist: $($profile.CurrentUserAllHosts)"
  "append current profile..."
} else {
  "create new profile.CurrentUserAllHosts: $($profile.CurrentUserAllHosts)"
  New-Item -ItemType File -Path $profile.CurrentUserAllHosts -Force
}
Add-Content -Path $profile.CurrentUserAllHosts -Value ". $PSScriptRoot\profile.ps1"
'profile setup done!'

[System.Environment]::SetEnvironmentVariable("MS_PWSH", $PSScriptRoot, 'User')
$env:MS_PWSH = $PSScriptRoot
$env:PSModulePath += ";$PSScriptRoot\..\Module"
$env:path += ";$PSScriptRoot\Cmdlet"