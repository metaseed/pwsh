if (Test-Path $profile.CurrentUserAllHosts) {
  "profile.CurrentUserAllHosts already exist: $($profile.CurrentUserAllHosts)"
  "append current profile..."
} else {
  "create new profile.CurrentUserAllHosts: $($profile.CurrentUserAllHosts)"
  New-Item -ItemType File -Path $profile.CurrentUserAllHosts -Force
}

$p = ". $PSScriptRoot\profile.ps1"
$has = gc $profile.CurrentUserAllHosts |? {$_ -like $p}
if(!$has) {
  Add-Content -Path $profile.CurrentUserAllHosts -Value $p
  'profile setup done!'
} else {
  "already added to profie: $p"
}

[System.Environment]::SetEnvironmentVariable("MS_PWSH", $PSScriptRoot, 'User')
$env:MS_PWSH = $PSScriptRoot

$env:PSModulePath += ";$(Resolve-Path $PSScriptRoot\..\Module)"
$env:path += ";$PSScriptRoot\Cmdlet"