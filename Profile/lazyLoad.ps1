# $LazyLoadProfile = [PowerShell]::Create()
# [void]$LazyLoadProfile.AddScript(@'
#     # Import-Module posh-git
# '@)
# $LazyLoadProfileRunspace = [RunspaceFactory]::CreateRunspace()
# $LazyLoadProfile.Runspace = $LazyLoadProfileRunspace
# $LazyLoadProfileRunspace.Open()
# [void]$LazyLoadProfile.BeginInvoke()

# $null = Register-ObjectEvent -InputObject $LazyLoadProfile -EventName InvocationStateChanged -Action {
#     # Import-Module -Name posh-git
#     # . $PSScriptRoot\PSReadlineConfig.ps1
#     # . $PSScriptRoot\terminal\terminal.ps1
#     # . $PSScriptRoot\configPsFzf.ps1
#     # . $PSScriptRoot\PS-GuiCompletion.ps1

#     # $global:GitPromptSettings.DefaultPromptPrefix.Text = 'PS1 '
#     # $global:GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'
#     $LazyLoadProfile.Dispose()
#     $LazyLoadProfileRunspace.Close()
#     $LazyLoadProfileRunspace.Dispose()
#     . $PSScriptRoot\posh-git.ps1
# }

$timer = [Timers.Timer]::new(2000)
$timer.AutoReset = $false
$null = Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {
  $timer.Dispose()
    # Import-Module -Name posh-git
    # $GitPromptSettings.DefaultPromptPrefix.Text = 'PS1 '
    # $global:GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'
  . $PSScriptRoot\posh-git.ps1
  . $PSScriptRoot\PSReadlineConfig.ps1
  . $PSScriptRoot\terminal\terminal.ps1
  . $PSScriptRoot\configPsFzf.ps1
  . $PSScriptRoot\PS-GuiCompletion.ps1
}
$timer.start()