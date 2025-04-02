@{
  Author            = 'Metaseed'
  NestedModules     = @('_bin\Metaseed.PSManagement.dll','Metaseed.Management.psm1')
  ModuleVersion     = '1.0.10'
  AliasesToExport = @('admin', 'const', 'crb', 'gsi', 'ndh', 'npsd', 'opkf', 'opss', 'orb', 'ris', 'rn', 'shrs', 'sln', 'stea', 'trash', 'wct')
  CmdletsToExport = @('Invoke-NonAdmin')
  FunctionsToExport = @('Add-PathEnv', 'Assert-Admin', 'Close-Explorer', 'Config-WindowsLibrary', 'Download-GithubRelease', 'Get-AppInstallation', 'Get-Appx', 'Get-FolderSizeInfo', 'Get-Fonts', 'Get-FTA', 'Get-GithubRelease', 'Get-LastDeletedItems', 'Get-LocalAppInfo', 'Get-OpenedExplorer', 'Get-PendingReboot', 'Get-ProcessFromPort', 'Get-PTA', 'Get-RecycledItem', 'Install-App', 'Install-Font', 'Install-FromGithub', 'Install-FromWeb', 'Invoke-Admin', 'New-AdminShell', 'New-PSDriveHere', 'New-ShortCut', 'Open-KnownFolder', 'open-recycleBin', 'Open-SystemSetting', 'Pin-TaskBar', 'Register-FTA', 'Remove-EmptyDirectory', 'Remove-EnvVarDuplicateValues', 'Remove-ItemSafely', 'Repair-AclCorruption', 'Restore-RecycledItem', 'Set-FTA', 'Set-KnownFolderPath', 'Set-ModifyPermission', 'Set-ShortcutElevation', 'Set-StartTask', 'Show-RecycleBinSize', 'Sleep-Computer', 'Start-Explorer', 'sudo', 'Test-Admin', 'Test-AppInstallation', 'Test-ProcessElevated', 'Uninstall-Apps', 'Uninstall-Appx', 'Uninstall-Font', 'Update-ProcessEnvVar', 'Update-ProcessEnvVarPath', 'Watch-Table')
  FormatsToProcess     = @('folderSize\get-folderSizeInfo.ps1xml')
}
