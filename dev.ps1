
[CmdletBinding()]
param (
  # clone the source code into the pwsh sub-folder of the folder
  [Parameter()]
  [string]$PWSHFolder
)

# install pwsh 7
if ($PSVersionTable.PSVersion.Major -lt 7) {
  write-error "please install powershell version great than 7"
  write-host "https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows"
  return
}

if (Test-Path $PWSHFolder -PathType leaf) {
  write-error "a file $PWSHFolder already exists, please remove it first or try a different folder"
  return
}


if (!(Test-Path $PWSHFolder -PathType Container)) {
  write-host "$PWSHFolder does not exist, create it..."
  New-Item -ItemType Directory -Path $PWSHFolder -Force | Out-Null
}

try {
  $root = "$PWSHFolder\pwsh"

  Push-Location $PWSHFolder
  git clone http://github.com/metasong/pwsh.git --depth 1

  . "$root/config.ps1"
  if (! (test-path "$root/.local")) {
    write-host "creating .local file"
    New-Item -itemtype file -Force -Path "$root/.local" | Out-Null
  }
  code $root
  code $PROFILE.CurrentUserAllHosts
}
catch {
  write-error $_.Exception.Message
}
finally {
  Pop-Location
}
