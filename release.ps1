[CmdletBinding()]
param (
  [Parameter()]
  [string]
  [ValidateSet('major', 'minor', 'build')]
  $Bump = 'patch'
)

$info = (Get-Content "$PSScriptRoot\info.json") | ConvertFrom-Json | % {
  $version = [Version] $_.version
  $major = $version.Major
  $minor = $version.Minor
  $build = $version.Build
  if ($Bump -eq 'major') { $major = $version.Major + 1 }
  elseif ($Bump -eq 'minor') { $minor = $version.Minor + 1 }
  else { $build = $version.Build + 1 }
  $_.version = "$major.$minor.$build"
  $_
}|
ConvertTo-Json|
Set-Content "$PSScriptRoot\info.json"

$msg = "release $($info.version)"
git commit -am $msg
git tag -a "'$info.version'" -m "'$msg'"
git push --tags