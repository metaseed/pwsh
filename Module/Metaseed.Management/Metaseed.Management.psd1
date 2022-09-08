@{
  RootModule        = 'Metaseed.Management.psm1'
  ModuleVersion     = '1.0.7'
  AliasesToExport = @('admin', 'crb', 'gri', 'oprb', 'ris', 'rri', 'shrs', 'trash')
  CmdletsToExport = @()
  FunctionsToExport = @('Add-PathEnv', 'Assert-Admin', 'Download-GithubRelease', 'Get-Appx', 'Get-Fonts', 'Get-GithubRelease', 'Get-PendingReboot', 'Get-RecycledItem', 'Install-Font', 'Install-FromGithub', 'Invoke-Admin', 'New-AdminShell', 'New-ShortCut', 'open-recycleBin', 'Open-ShellFolder', 'Pin-TaskBar', 'Remove-DuplicationEnvVarValue', 'Remove-ItemSafely', 'Repair-AclCorruption', 'Restore-RecycledItem', 'Set-KnownFolderPath', 'Set-ModifyPermission', 'Set-ShortcutElevation', 'Set-StartTask', 'Show-RecycleBinSize', 'sudo', 'Test-Admin', 'Uninstall-Apps', 'Uninstall-Appx', 'Uninstall-Font', 'Update-EnvVar')
}
