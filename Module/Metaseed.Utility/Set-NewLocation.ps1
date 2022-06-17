# make and change directory
function Set-NewLocation {
  [CmdletBinding()]
  param(
      [Parameter(Mandatory = $true)]
      [string]
      $Path,
      [switch]
      [alias('f')]
      $Force
  )
  # mkdir path
  if($Force -and (Test-Path $Path -PathType Container)) {
      Remove-Item -Path $Path -Force -recurse 
      New-Item -ItemType Directory -Force -Path $Path -ErrorAction Stop
  } else {
      New-Item -ItemType Directory -Path $Path -ErrorAction Stop
  }

  # cd path
  Set-Location -Path $Path
}

New-Alias snl Set-NewLocation
