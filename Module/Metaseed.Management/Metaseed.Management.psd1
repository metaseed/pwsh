@{
  RootModule        = 'Metaseed.Management.psm1'
  ModuleVersion     = '1.0.8'
  AliasesToExport = @('admin', 'crb', 'gri', 'gsi', 'ndh', 'npsd', 'opkf', 'opss', 'orb', 'ris', 'rri', 'shrs', 'stea', 'trash', 'wct')
  CmdletsToExport = @()
  FunctionsToExport = @('Add-PathEnv', 'Assert-Admin', 'Download-GithubRelease', 'Get-Appx', 'Get-FolderSizeInfo', 'Get-Fonts', 'Get-FTA', 'Get-GithubRelease', 'Get-LocalAppInfo', 'Get-PendingReboot', 'Get-PTA', 'Get-RecycledItem', 'Install-App', 'Install-Font', 'Install-FromGithub', 'Invoke-Admin', 'New-AdminShell', 'New-PSDriveHere', 'New-ShortCut', 'Open-KnownFolder', 'open-recycleBin', 'Open-SystemSetting', 'Pin-TaskBar', 'Register-FTA', 'Remove-DuplicationEnvVarValue', 'Remove-EmptyDirectory', 'Remove-ItemSafely', 'Repair-AclCorruption', 'Restore-RecycledItem', 'Set-FTA', 'Set-KnownFolderPath', 'Set-ModifyPermission', 'Set-ShortcutElevation', 'Set-StartTask', 'Show-RecycleBinSize', 'Sleep-Computer', 'Start-ExplorerInAdmin', 'sudo', 'Test-Admin', 'Test-AppInstallation', 'Test-ProcessElevated', 'Uninstall-Apps', 'Uninstall-Appx', 'Uninstall-Font', 'Update-EnvVar', 'Watch-Table')
  FormatsToProcess     = @('folderSize\get-folderSizeInfo.ps1xml')
}
