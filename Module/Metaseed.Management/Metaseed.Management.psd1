@{
  RootModule        = 'Metaseed.Management.psm1'
  ModuleVersion     = '1.0.5'
  CmdletsToExport   = @('')
  FunctionsToExport = @('Uninstall-Appx','Add-Path', 'Assert-Admin', 'Download-GithubRelease', 'Get-Appx', 'Get-Fonts', 'Get-GithubRelease', 'Get-PendingReboot', 'Install-Font', 'Invoke-Admin', 'New-Admin', 'New-ShortCut', 'Pin-TaskBar', 'Remove-DuplicationEnvVarValue', 'Set-KnownFolderPath', 'Set-ShortcutElevation', 'Set-StartTask', 'sudo', 'Test-Admin', 'Uninstall-Apps', 'Uninstall-Font', 'Update-EnvVar')
}
