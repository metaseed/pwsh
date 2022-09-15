@{
  RootModule        = 'Metaseed.Management.psm1'
  ModuleVersion     = '1.0.7'
  AliasesToExport = @('admin', 'crb', 'gri', 'gsi', 'ndh', 'npsd', 'okf', 'oprb', 'ris', 'rri', 'shrs', 'sht', 'trash')
  CmdletsToExport = @()
  FunctionsToExport = @('Add-PathEnv', 'Assert-Admin', 'Download-GithubRelease', 'Get-Appx', 'Get-FolderSizeInfo', 'Get-Fonts', 'Get-GithubRelease', 'Get-PendingReboot', 'Get-RecycledItem', 'Install-Font', 'Install-FromGithub', 'Invoke-Admin', 'New-AdminShell', 'New-PSDriveHere', 'New-ShortCut', 'Open-KnownFolder', 'open-recycleBin', 'Pin-TaskBar', 'Remove-DuplicationEnvVarValue', 'Remove-ItemSafely', 'Repair-AclCorruption', 'Restore-RecycledItem', 'Set-KnownFolderPath', 'Set-ModifyPermission', 'Set-ShortcutElevation', 'Set-StartTask', 'Show-RecycleBinSize', 'Show-Table', 'sudo', 'Test-Admin', 'Uninstall-Apps', 'Uninstall-Appx', 'Uninstall-Font', 'Update-EnvVar')
  FormatsToProcess     = @('folderSize\get-folderSizeInfo.ps1xml')
}
