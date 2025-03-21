<#
1. in repo directory, and search to the parent folder, until find the info.json
1. increase the build version
1. commit the changes and push the remote
#>
[CmdletBinding()]
param (
  # the version part
  [Parameter()]
  [string]
  [ValidateSet('minor', 'build')]
  $Part = 'build',

  [switch]
  $NoPush
)
Write-SubStep 'try to find info.json...'
$info = Find-FromParent 'info.json'
if($null -eq $info) {
  # not we have warning msg from Find-FromParent, no need to print error
  return
}

Write-Host "find info.json at: $($info.FullName)"

Write-SubStep 'bump version...'
Write-Action 'get version info from info.json...'

# "version": "{{release}}.0.414"
$regex = '"version"\s*:\s*"(.*)\.(.*)\.(\d+)"'
$str = select-string -path $info $regex
if ($null -eq $str.Matches) {
  Write-Warning "could not find the version information`n$(Get-Content $info)"
  return
}
Write-Notice "old $($str.Matches[0].Value)"

Write-Action "increase $Part version"
if ($str.Matches.Success) {
  $major = $str.Matches.Groups[1].Value
  $minor = $str.Matches.Groups[2].Value
  $build = $str.Matches.Groups[3].Value
}

if ($Part -eq 'minor') {
  $minor = ( + ($minor)) + 1
}
else {
  $build = ( + ($build)) + 1
}
$newVer = "`"version`": `"$major.$minor.$build`""

Write-Action 'modify version of info.json...'
# note the parentheses around get-content to ensure the file is slurped in one go(closed)
(Get-Content $info) |
% { $_ -replace $regex, $newVer } |
Set-Content $info -force
Write-Notice "new $newVer"
if (!$NoPush) {
  Write-SubStep 'commit changes...'
  Write-Execute "git status"
  # code $info # it will bring code as active
  # Confirm-Continue
  Write-Execute "git add $info"
  Write-Execute "git commit -m 'bump $newVer'"
  git-push
}