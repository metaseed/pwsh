$timer = [Timers.Timer]::new(2000)
$timer.AutoReset = $false
$null = Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {

  . $PSScriptRoot\PSReadlineConfig.ps1
  . $PSScriptRoot\terminal\terminal.ps1
  . $PSScriptRoot\configPsFzf.ps1
  . $PSScriptRoot\PS-GuiCompletion.ps1

  $timer.Dispose()
}
$timer.start()