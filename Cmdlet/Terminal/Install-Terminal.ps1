[CmdletBinding()]
param (
    [Parameter()]
    [string]
    [ValidateSet('Win10', 'Win11')]
    $platform = 'Win10'
)
Assert-Admin

Write-Step 'query latest version...'
(iwr https://github.com/microsoft/terminal/releases/latest) -match "(?<=<a href=`").*Microsoft.WindowsTerminal_$platform_.*\.msixbundle" |out-null
$url = "http://github.com$($matches[0])"
$file = ($url -split '/')[-1]
write-host $file
"$file" -match "_(\d+\.\d+\.\d+\.\d+)_"
$ver_online = [Version]::new($matches[1]);
Write-substep 'checking installed version...'
Import-Module Appx -UseWindowsPowerShell *>$null
$t = Get-AppxPackage *WindowsTerminal*
if($t.Version -ge $ver_online) {
  Write-Warning 'already latest version, no need to update'
  return 1
}

Write-Step 'check running WindowsTerminal...'
$wts = get-process -name "WindowsTerminal" -ErrorAction SilentlyContinue
if ($wts) {
  Confirm-Continue "Windows Terminal is running. Do you want to kill it?"

  $Wt = Get-ParentProcessByName -processName 'WindowsTerminal'
  if ($Wt) {
    $path = $MyInvocation.MyCommand.Path
    Start-Process pwsh -verb runas -ArgumentList @( "-NoExit", "-File", "$path","$processName" )
  }
  stop-process -name "WindowsTerminal" -force
}

Write-Step 'download windows terminal...'
iwr $url -OutFile "$env:temp/$file"
Write-Step 'install windows terminal...'
write-host "Add-AppxPackage '$env:temp/$file'"
Add-AppxPackage "$env:temp/$file"
Setup-Terminal
Confirm-Continue "if err:`n please kill the 'Terninal' task in task manager and try again with: `n Add-AppxPackage '$env:temp/$file'"