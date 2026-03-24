# used for update pwsh 7 to latest version.
Assert-Admin

Install-FromGithub 'Powershell/Powershell' 'win-x64.msi$' -versionType 'stable' -getLocalInfoScript {
  @{ver=$PSVersionTable.PSVersion;folder=$null}
} -installScript {
  param($downloadedFilePath, $ver_online, $toFolder, $newName)

  Confirm-Continue "to install power shell: $downloadedFilePath, `nwe would kill all running pwsh processes.`n"
  $msi = Start-Process msiexec.exe -PassThru -ArgumentList "/package $downloadedFilePath /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1"
  # Use Windows PowerShell 5.1 (powershell.exe) to wait and notify, since pwsh processes get killed
  Start-Process powershell.exe -WindowStyle Hidden -ArgumentList "-Command", "Wait-Process -Id $($msi.Id) -ErrorAction SilentlyContinue; [Console]::Beep(800, 300); Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('PowerShell(ver: $ver_online) installation completed!', 'Install-Pwsh')"

  Write-Notice "installation started in background, you will be notified when it completes."
  Get-Process -Name pwsh | Stop-Process -Force
} @args