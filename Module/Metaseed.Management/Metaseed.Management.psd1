@{
  RootModule        = 'Metaseed.Management.psm1'
  ModuleVersion     = '1.0.8'
  AliasesToExport = @('admin', 'crb', 'gri', 'gsi', 'ndh', 'npsd', 'opkf', 'opss', 'orb', 'ris', 'rri', 'shrs', 'trash', 'wct')
  CmdletsToExport = @()
  FunctionsToExport = @('Add-PathEnv', 'Assert-Admin', 'Download-GithubRelease', 'Get-Appx', 'Get-FolderSizeInfo', 'Get-Fonts', 'Get-GithubRelease', 'Get-PendingReboot', 'Get-RecycledItem', 'Install-Font', 'Install-FromGithub', 'Invoke-Admin', 'New-AdminShell', 'New-PSDriveHere', 'New-ShortCut', 'Open-KnownFolder', 'open-recycleBin', 'Open-SystemSetting', 'Pin-TaskBar', 'Remove-DuplicationEnvVarValue', 'Remove-ItemSafely', 'Repair-AclCorruption', 'Restore-RecycledItem', 'Set-KnownFolderPath', 'Set-ModifyPermission', 'Set-ShortcutElevation', 'Set-StartTask', 'Show-RecycleBinSize', 'Sleep-Computer', 'sudo', 'Test-Admin', 'Uninstall-Apps', 'Uninstall-Appx', 'Uninstall-Font', 'Update-EnvVar', 'Watch-Table')
  FormatsToProcess     = @('folderSize\get-folderSizeInfo.ps1xml')
}
