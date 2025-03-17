$LazyLoadProfile = [PowerShell]::Create()
# https://gist.github.com/hyrious/65c85889e18e916fe0a170f919afb5c1
[void]$LazyLoadProfile.AddScript(@'
    Import-Module posh-git -DisableNameChecking -Scope Global -ArgumentList @($true)
'@)
<#
https://devblogs.microsoft.com/powershell/powershell-runspace-debugging-part-1/
A Runspace is an instance of the PowerShell engine within a process.  It defines the context in which a PowerShell command or script runs and contains state that is specific to your PowerShell session, including variables and functions that you define, modules that you load, etc.  Normally your ISE or console has a single (default) Runspace, but you can have more than one.
#>
$LazyLoadProfile.Runspace = $LazyLoadProfileRunspace = [RunspaceFactory]::CreateRunspace()
$LazyLoadProfileRunspace.Name = 'LazyLoading'
$LazyLoadProfileRunspace.Open()
[void]$LazyLoadProfile.BeginInvoke()

$null = Register-ObjectEvent -InputObject $LazyLoadProfile -EventName InvocationStateChanged -Action {
  # note: below script is executed in the background job with a Guid as its name
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
# when debug: to show error, in console:
# Get-Job | Receive-Job -Keep
# Get-Job|stop-job|remove-job