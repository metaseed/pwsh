
[CmdletBinding()]
param (
  # local source folder to clone the source code
  [Parameter()]
  [string]$PWSHFolder
)
if (Test-Path $PWSHFolder -PathType leaf) {
  write-error "a file $PWSHFolder already exists"
  return
}
if (! (Test-Path $PWSHFolder -PathType Container)) {
  write-host "$PWSHFolder does not exist, create it..."
  New-Item -ItemType Directory -Path $PWSHFolder -Force | Out-Null
}

try {
  Push-Location $PWSHFolder
  git clone http://github.com/metasong/pwsh.git --depth 1

  $root = "$PWSHFolder\pwsh"
  . "$root/config.ps1"
  if (! (test-path "$root/.local")) {
    write-host "creating .local file"
    New-Item -itemtype file -Force -Path "$root/.local" | Out-Null
  }
  code $root
}
catch {
  write-error $_.Exception.Message
}
finally {
  Pop-Location
}
