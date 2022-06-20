[CmdletBinding()]
param (
  [Parameter()]
  [string]
  [ValidateSet('Win10', 'Win11')]
  $platform = 'Win10',
  [Parameter()]
  [string]
  [ValidateSet('preview', 'stable')]
  $version = 'preview',
  [Parameter()]
  [switch]
  [alias('f')]
  $force

)
Assert-Admin

Breakable-Pipeline {
  Get-GithubRelease -OrgName 'microsoft' -RepoName 'terminal' -version $version -fileNamePattern "_$($platform)_.*\.msixbundle$" |
  % {
    $assets = $_
    if ($assets.Count -ne 1 ) {
      foreach ($asset in $assets) {
        Write-Host $asset.name
      }
      Write-Error "Expected one asset, but found $assets.Count"
      break;
    }
    $file = $assets[0].name
    write-host $file
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

    Write-Step 'download windows terminal...'
    return $_
  } |
  Download-GithubRelease |
  % {
    Write-Step 'check running WindowsTerminal...'
    $install = @"
    & {
      start-sleep -s 2
      Write-Step 'install windows terminal...'
      write-host `"Add-AppxPackage '$env:temp\$file'`"
      Import-Module Appx -UseWindowsPowerShell *>`$null
      Add-AppxPackage `"$env:temp/$file`"
      Write-host `"when err: please kill the 'Terninal' task in task manager and try again with:  Add-AppxPackage '$env:temp\$file'`"
      Setup-Terminal
    }
"@

    $wts = get-process -name "WindowsTerminal" -ErrorAction SilentlyContinue
    if ($wts) {
      Confirm-Continue "Windows Terminal is running. Do you want to kill it?"

      $Wt = Get-ParentProcessByName -processName 'WindowsTerminal'
      if ($Wt) {
        # $path = $MyInvocation.MyCommand.Path
        Start-Process pwsh -verb runas -ArgumentList @( "-NoExit", "-Command", $install )
      }
      else {
        pwsh -NoExit -Command $install
      }
      stop-process -name "WindowsTerminal" -force
      stop-process -name "OpenConsole" -force
     
    }
    else {
      pwsh -NoExit -Command $install
    }
  }
}