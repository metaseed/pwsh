@{
  Author            = 'Metaseed'
  NestedModules     = @('_bin\Metaseed.PSManagement.dll','Metaseed.Management.psm1')
  ModuleVersion     = '1.0.9'
  AliasesToExport = @('admin', 'crb', 'gri', 'gsi', 'ndh', 'npsd', 'opkf', 'opss', 'orb', 'ris', 'rn', 'rri', 'shrs', 'stea', 'trash', 'wct')
  CmdletsToExport = @('Invoke-NonAdmin')
  FunctionsToExport = @('Add-PathEnv', 'Assert-Admin', 'Close-Explorer', 'Download-GithubRelease', 'Get-Appx', 'Get-Explorer', 'Get-FolderSizeInfo', 'Get-Fonts', 'Get-FTA', 'Get-GithubRelease', 'Get-LocalAppInfo', 'Get-PendingReboot', 'Get-ProcessFromPort', 'Get-PTA', 'Get-RecycledItem', 'Install-App', 'Install-Font', 'Install-FromGithub', 'Invoke-Admin', 'New-AdminShell', 'New-PSDriveHere', 'New-ShortCut', 'Open-KnownFolder', 'open-recycleBin', 'Open-SystemSetting', 'Pin-TaskBar', 'Register-FTA', 'Remove-DuplicationEnvVarValue', 'Remove-EmptyDirectory', 'Remove-ItemSafely', 'Repair-AclCorruption', 'Restore-RecycledItem', 'Set-FTA', 'Set-KnownFolderPath', 'Set-ModifyPermission', 'Set-ShortcutElevation', 'Set-StartTask', 'Show-RecycleBinSize', 'Sleep-Computer', 'Start-Explorer', 'sudo', 'Test-Admin', 'Test-AppInstallation', 'Test-ProcessElevated', 'Uninstall-Apps', 'Uninstall-Appx', 'Uninstall-Font', 'Update-EnvVar', 'Watch-Table')
  FormatsToProcess     = @('folderSize\get-folderSizeInfo.ps1xml')
}
