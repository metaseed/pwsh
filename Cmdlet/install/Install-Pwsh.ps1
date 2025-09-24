# used for update pwsh 7 to latest version.
[CmdletBinding()]
param(
  [parameter(Position=0,ValueFromRemainingArguments)]
  [string[]]
  $Remaining
)
Assert-Admin

Install-FromGithub 'Powershell/Powershell' 'win-x64.msi$' -versionType 'stable' -getLocalInfoScript {
  @{ver=$PSVersionTable.PSVersion;folder=$null}
} -installScript {
  param($downloadedFilePath, $ver_online, $toFolder, $newName)

  Confirm-Continue "to install power shell: $downloadedFilePath, `nwe would kill all running pwsh processes.`n"
  Start-Process msiexec.exe -ArgumentList "/package $downloadedFilePath /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1"
  Write-Notice "installation started in background, please check later..."
  Get-Process -Name pwsh | Stop-Process -Force
} @Remaining