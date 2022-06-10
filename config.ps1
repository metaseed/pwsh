if (Test-Path $profile.CurrentUserAllHosts) {
  write-host "profile.CurrentUserAllHosts already exist: $($profile.CurrentUserAllHosts)"
}
else {
  write-host "create new profile.CurrentUserAllHosts: $($profile.CurrentUserAllHosts)"
  New-Item -ItemType File -Path $profile.CurrentUserAllHosts -Force | Out-Null
}
## set profile
$p = ". $(Resolve-Path $PSScriptRoot\profile.ps1)"
$has = gc $profile.CurrentUserAllHosts | ? { $_ -like $p }
if (!$has) {
  $has1 = $false
  $p1 = ''
  if ($env:MS_PWSH) {
    $p1 = ". $(Resolve-Path $env:MS_PWSH\profile.ps1)"
    $has1 = gc $profile.CurrentUserAllHosts | ? { $_ -like $p1 }
  }
  if ($has1) {
    # means $MS_PWSH is not the current $PSScriptRoot
    (Get-Content $profile.CurrentUserAllHosts) | % { $_.Replace($p1, $p) }| set-content $profile.CurrentUserAllHosts -Force
    write-host "replace $p1 with $p in $($profile.CurrentUserAllHosts)"
  } 
  else {
    Add-Content -Path $profile.CurrentUserAllHosts -Value $p
    Write-Host "append profile ($p) to $($profile.CurrentUserAllHosts)"
  }
}
else {
  write-host "no action, because already added to profie: $p"
}
## environment variables
[System.Environment]::SetEnvironmentVariable("MS_PWSH", $PSScriptRoot, 'User')
$env:MS_PWSH = $PSScriptRoot
write-host "set env:MS_PWSH to $($env:MS_PWSH)"

. $PSScriptRoot\profile.ps1