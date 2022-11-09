[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $force
)

if($force) {
  . $env:MS_PWSH\dev.ps1
  return
}

Push-Location $env:MS_PWSH

git pull

Pop-Location