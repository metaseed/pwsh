$LazyLoadProfile = [PowerShell]::Create()
# https://gist.github.com/hyrious/65c85889e18e916fe0a170f919afb5c1
[void]$LazyLoadProfile.AddScript(@'
    Import-Module posh-git -DisableNameChecking -Scope Global -ArgumentList @($true)
'@)
<#
https://devblogs.microsoft.com/powershell/powershell-runspace-debugging-part-1/
A Runspace is an instance of the PowerShell engine within a process.  It defines the context in which a PowerShell command or script runs and contains state that is specific to your PowerShell session, including variables and functions that you define, modules that you load, etc.  Normally your ISE or console has a single (default) Runspace, but you can have more than one.
#>
## this way the input response a bit then event run, not response again.
<#
$LazyLoadProfile.Runspace = $LazyLoadProfileRunspace = [RunspaceFactory]::CreateRunspace()
$LazyLoadProfileRunspace.Name = 'LazyLoading'
$LazyLoadProfileRunspace.Open()
[void]$LazyLoadProfile.BeginInvoke()
$null = Register-ObjectEvent -InputObject $LazyLoadProfile -EventName InvocationStateChanged -Action {
  # note: below script is executed in the background job with a Guid as its name
  . $PSScriptRoot\_main.ps1
  # we instead using Invoke-FzfTabCompletion, because it support fuzzy search
  # . $PSScriptRoot\PS-GuiCompletion.ps1
  $LazyLoadProfile.Dispose()
  $LazyLoadProfileRunspace.Close()
  $LazyLoadProfileRunspace.Dispose()
}
. $PSScriptRoot\yazi.config.ps1
#>

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


## this way the input not response after profile loading
# $action = {
#   # Put your slow commands here
#   . $PSScriptRoot\_main.ps1
#   function global:A {
#         # 'cd -' looks at the history of the scope it's running in.
#         # By making this global, it sees YOUR history.
#         Set-Location -Path -
#     }
#   Unregister-Event -SourceIdentifier "OnProfileReady" # Run only once
# }

# Register-EngineEvent -SourceIdentifier "PowerShell.OnIdle" -Action $action -SupportEvent

# all the lazy loading is kind of fake, the input is not responding well.