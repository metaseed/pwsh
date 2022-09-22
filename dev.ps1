
[CmdletBinding()]
param (
  # clone the source code into the pwsh sub-folder of the folder
  [Parameter()]
  [string]$PWSHParentFolder
)

# install pwsh 7
if ($PSVersionTable.PSVersion.Major -lt 7) {
  write-error "please install powershell version great than 7"
  write-host "https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows"
  return
}

if (Test-Path $PWSHParentFolder -PathType leaf) {
  write-error "a file $PWSHParentFolder already exists, please remove it first or try a different folder"
  return
}


if (!(Test-Path $PWSHParentFolder -PathType Container)) {
  write-host "$PWSHParentFolder does not exist, create it..."
  New-Item -ItemType Directory -Path $PWSHParentFolder -Force | Out-Null
}

$root = "$PWSHParentFolder\pwsh"
if (Test-Path $root -type Container) {
  try {
    Push-Location $root
    $status = git status
    $dirtyMsg = $status -match 'modified:|Untracked files:|Your branch is ahead of'
    if ($dirtyMsg.length -gt 0) {
      $decision = $Host.UI.PromptForChoice('Override Local Changes?', "You have local changes in $root?,`ndo you want to continue to hard reset local changes?", @('&Yes', '&No'), 0)
      if ($decision -eq 0) {
        git reset --hard
        # Remove-Item -force -Recurse "$root"
      } else {
        'please check local changes and rerun the command'
        return
      }
    }
  }
  finally {
    Pop-Location
  }
}


try {
  Push-Location $PWSHParentFolder
  if (gci 'pwsh') {
    Push-Location 'pwsh'
    git pull
    Pop-Location
  }
  else {
    git clone http://github.com/metasong/pwsh.git --depth 1
  }

  . "$root/config.ps1"

  code $root
  code $PROFILE.CurrentUserAllHosts
}
catch {
  write-error $_.Exception.Message
}
finally {
  Pop-Location
}
