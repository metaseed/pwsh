@{
  RootModule        = 'Metaseed.Management.psm1'
  ModuleVersion     = '1.0.7'
  AliasesToExport = @('admin')
  CmdletsToExport = @()
  FunctionsToExport = @('Add-PathEnv', 'Assert-Admin', 'Download-GithubRelease', 'Get-Appx', 'Get-Fonts', 'Get-GithubRelease', 'Get-PendingReboot', 'Get-RecycledItem', 'Install-Font', 'Install-FromGithub', 'Invoke-Admin', 'New-Admin', 'New-ShortCut', 'Pin-TaskBar', 'Remove-DuplicationEnvVarValue', 'Remove-ItemSafely', 'Restore-RecycledItem', 'Set-KnownFolderPath', 'Set-ShortcutElevation', 'Set-StartTask', 'sudo', 'Test-Admin', 'Uninstall-Apps', 'Uninstall-Appx', 'Uninstall-Font', 'Update-EnvVar')
}
