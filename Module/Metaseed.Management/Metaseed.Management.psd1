@{
  RootModule        = 'Metaseed.Management.psm1'
  ModuleVersion     = '1.0.7'
  FormatsToProcess     = @('folderSize\get-folderSizeInfo.ps1xml')
  AliasesToExport = @('admin', 'crb', 'gri', 'ndh', 'npsd', 'okf', 'oprb', 'ris', 'rri', 'shrs', 'trash')
  CmdletsToExport = @()
  FunctionsToExport = @('Get-FolderSizeInfo','Add-PathEnv', 'Assert-Admin', 'Download-GithubRelease', 'Get-Appx', 'Get-Fonts', 'Get-GithubRelease', 'Get-PendingReboot', 'Get-RecycledItem', 'Install-Font', 'Install-FromGithub', 'Invoke-Admin', 'New-AdminShell', 'New-PSDriveHere', 'New-ShortCut', 'Open-KnownFolder', 'open-recycleBin', 'Pin-TaskBar', 'Remove-DuplicationEnvVarValue', 'Remove-ItemSafely', 'Repair-AclCorruption', 'Restore-RecycledItem', 'Set-KnownFolderPath', 'Set-ModifyPermission', 'Set-ShortcutElevation', 'Set-StartTask', 'Show-RecycleBinSize', 'sudo', 'Test-Admin', 'Uninstall-Apps', 'Uninstall-Appx', 'Uninstall-Font', 'Update-EnvVar')
}
