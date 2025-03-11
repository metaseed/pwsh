[CmdletBinding()]
param (
  [Parameter()]
  [string]
  [ValidateSet('Win10', 'Win11')]
  $platform = 'Win10',
  [Parameter()]
  [string]
  [ValidateSet('preview', 'stable')]
  $version = 'stable',
  [Parameter()]
  [switch]
  [alias('f')]
  $force

)
Assert-Admin

Breakable-Pipeline {
  if($platform -eq 'Win11') {
    $download = Get-GithubRelease -OrgName 'microsoft' -RepoName 'terminal' -version $version -fileNamePattern ".*\.msixbundle$"
  } else {
    $download = Get-GithubRelease -OrgName 'microsoft' -RepoName 'terminal' -version $version -fileNamePattern "_Windows10_.*\.zip$"
  }

  $download|
  % {
    $assets = $_
    if ($assets.Count -ne 1 ) {
      foreach ($asset in $assets) {
        Write-Host $asset.name
      }
      Write-Error "Expected one asset, but found $($assets.Count)"
      break; # break pipeline
    }
    $file = $assets[0].name
    write-host "online available: $file"
    "$file" -match "_(\d+\.\d+\.\d+\.\d+)_"
    $ver_online = [Version]::new($matches[1]);
    Write-substep 'checking installed version...'
    Import-Module Appx -UseWindowsPowerShell *>$null
    $t = Get-AppxPackage *WindowsTerminal*
    if ($t) {
      if ($t.Version -ge $ver_online -and !$force) {
        Write-Warning "already latest version: $ver_online, no need to update"
        break;
      }
      else {
        Write-Host $assets[0].releaseNote
        write-host "new version available:  $ver_online, local: $($t.Version)"
      }
    }
    else {
      write-host "version to install:  $ver_online"
    }

    # Write-Step 'download windows terminal...'
    return $_
  } |
  Download-GithubRelease |
  % {
    Write-Step 'check running WindowsTerminal...'
    $output = $_
    if($platform -eq 'Win10') {
      $folder = "$env:temp\windows_terminal$(get-date -format filedate)"
      Expand-Archive $output $folder
      $output = gci  "$folder\*.msixbundle"
    }

    $wts = get-process -name "WindowsTerminal" -ErrorAction SilentlyContinue
    $install = @"
    & {
      start-sleep -s 4
      Write-Step 'install windows terminal...'
      write-host `"Add-AppxPackage '$output'`"
      Import-Module Appx -UseWindowsPowerShell *>`$null
      Add-AppxPackage `"$env:temp/$file`"
      Write-host `"when err: please kill the 'Terminal' task in task manager and try again with:  Add-AppxPackage '$output'`"
      Setup-Terminal
      start-sleep -s 1
      wt -w _quake
      # stop-process -id ([System.Diagnostics.Process]::GetCurrentProcess().Id)
    }
"@
    if ($wts) {
      Confirm-Continue "Windows Terminal is running. Do you want to kill it?"

      $Wt = Get-ParentProcess -ParentProcessName 'WindowsTerminal'

      if ($Wt) {
        # $path = $MyInvocation.MyCommand.Path
        Start-Process pwsh -verb runas -ArgumentList @( "-NoExit", "-Command", $install )
      }
      else {
        pwsh -NoExit -Command $install
      }
      stop-process -name "WindowsTerminal", "OpenConsole", "ShellExperienceHost" -force

    }
    else {
      pwsh -NoExit -Command $install
    }
  }
}