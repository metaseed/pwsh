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
  $hasOld = $false
  $p1 = ''
  if ($env:MS_PWSH) {
    $p1 = ". $(Resolve-Path $env:MS_PWSH\profile.ps1)"
    $hasOld = gc $profile.CurrentUserAllHosts | ? { $_ -like $p1 }
  }
  if ($hasOld) {
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

## set $env:PSModulePath
$m = resolve-path("$PSScriptRoot\Module")
$env:PSModulePath += ";$m"

$modPath = [Environment]::GetEnvironmentVariable("PSModulePath", 'User')
if(-not $modPath) {
  $modPath = $m
} else {
  if($MS_PWSH -and ("$MS_PWSH\Module" -ne $m)) {
    if($modPath.Contains("$MS_PWSH\Module;")) {
      $modPath = $modPath.Replace("$MS_PWSH\Module;", "")
    } elseif($modPath.Contains("$MS_PWSH\Module")){
      $modPath = $modPath.Replace("$MS_PWSH\Module", "")
    }
  }

  if(-not $modPath.Contains($m)) {
    $modPath += ";$m"
  }
}
[Environment]::SetEnvironmentVariable("PSModulePath", $modPath, 'User')

## environment variables
[System.Environment]::SetEnvironmentVariable("MS_PWSH", $PSScriptRoot, 'User')
$env:MS_PWSH = $PSScriptRoot
write-host "set env:MS_PWSH to $($env:MS_PWSH)"

. $PSScriptRoot\profile.ps1