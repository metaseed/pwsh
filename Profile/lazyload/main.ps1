$LazyLoadProfile = [PowerShell]::Create()

[void]$LazyLoadProfile.AddScript(@'
    Import-Module posh-git -DisableNameChecking
'@)

$LazyLoadProfile.Runspace = $LazyLoadProfileRunspace = [RunspaceFactory]::CreateRunspace()
$LazyLoadProfileRunspace.Open()
[void]$LazyLoadProfile.BeginInvoke()

$null = Register-ObjectEvent -InputObject $LazyLoadProfile -EventName InvocationStateChanged -Action {
  . $PSScriptRoot\posh-git.ps1
  . $PSScriptRoot\PSReadlineConfig.ps1
  . $PSScriptRoot\terminal\terminal.ps1
  . $PSScriptRoot\configPsFzf.ps1


  # we instead using Invoke-FzfTabCompletion, because it support fuzzy search
  # . $PSScriptRoot\PS-GuiCompletion.ps1
  $LazyLoadProfile.Dispose()
  $LazyLoadProfileRunspace.Close()
  $LazyLoadProfileRunspace.Dispose()
}
# . $PSScriptRoot\configPsFzf.ps1

# $timer = [Timers.Timer]::new(2000)
# $timer.AutoReset = $false
# $null = Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {
#   $timer.Dispose()

# }
# $timer.start()


# note:
# when debug: to show error
# Get-Job | Receive-Job -Keep