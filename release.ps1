[CmdletBinding()]
param (
  [Parameter()]
  [string]
  [ValidateSet('major', 'minor', 'build')]
  $Bump = 'build'
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
}
$info|
ConvertTo-Json|
Set-Content "$PSScriptRoot\info.json"

$msg = "release $($info.version)"

git add -A
git commit -am $msg
git push
git tag -a "$($info.version)" -m "'$msg'"
git push --tags