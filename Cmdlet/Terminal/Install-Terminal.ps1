[CmdletBinding()]
param (
  [Parameter()]
  [string]
  [ValidateSet('Win10', 'Win11')]
  $platform = 'Win10',
  [Parameter()]
  [string]
  [ValidateSet('preview', 'stable')]
  $version = 'preview'
    
)
Assert-Admin

$assets = Get-GithubRelease -OrgName 'microsoft' -RepoName 'terminal' -version $version -fileNamePattern "_$($platform)_.*\.msixbundle$" -ErrorAction Stop

if ($assets.Count -ne 1 ) {
  foreach ($asset in $assets) {
    Write-Host $asset.name
  }
  Write-Error "Expected one asset, but found $assets.Count"
  return
}

$file = $assets[0].name
write-host $file
"$file" -match "_(\d+\.\d+\.\d+\.\d+)_"
$ver_online = [Version]::new($matches[1]);
Write-substep 'checking installed version...'
Import-Module Appx -UseWindowsPowerShell *>$null
$t = Get-AppxPackage *WindowsTerminal*
if ($t) {
  if ($t.Version -ge $ver_online) {
    Write-Warning 'already latest version, no need to update'
    return 1
  }
  else {
    write-host "new version available:  $ver_online, local: $t.Version"
  }
}
else {
  write-host "version available:  $ver_online"
}

Write-Step 'check running WindowsTerminal...'
$wts = get-process -name "WindowsTerminal" -ErrorAction SilentlyContinue
if ($wts) {
  Confirm-Continue "Windows Terminal is running. Do you want to kill it?"

  $Wt = Get-ParentProcessByName -processName 'WindowsTerminal'
  if ($Wt) {
    $path = $MyInvocation.MyCommand.Path
    Start-Process pwsh -verb runas -ArgumentList @( "-NoExit", "-File", "$path", "$processName" )
  }
  stop-process -name "WindowsTerminal" -force
}

Write-Step 'download windows terminal...'
Download-GithubRelease $assets
Write-Step 'install windows terminal...'
write-host "Add-AppxPackage '$env:temp/$file'"
Add-AppxPackage "$env:temp/$file"
Confirm-Continue "if err:`n please kill the 'Terninal' task in task manager and try again with: `n Add-AppxPackage '$env:temp/$file'"
Setup-Terminal