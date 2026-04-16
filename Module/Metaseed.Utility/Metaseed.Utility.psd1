@{
  Author            = 'Metaseed'
  NestedModules     = @('_bin\Metaseed.PSUtility.dll','Metaseed.Utility.psm1')
  # RootModule = 'Metaseed.Utility.psm1'
  ModuleVersion = '1.0.5'
  AliasesToExport = @('cc', 'const', 'cs', 'cv', 'oc', 'os', 'ov', 'sln', 'unlock')
  CmdletsToExport = @('Get-ActiveComObject', 'Test-SampleCmdlet')
  FunctionsToExport = @('Backup-OneDriveFiles', 'Breakable-Pipeline', 'Close-Code', 'Close-Cursor', 'Close-VisualStudioSolution', 'Find-FromParent', 'Find-LockingProcess', 'Find-PsReadlinePath', 'Get-DateFromLunar', 'Get-DotnetVersions', 'Get-ErrorDetails', 'Get-LunarDate', 'Get-ParentProcess', 'Get-ProcessTree', 'Get-RedirectedUrl', 'Get-RemainParametersString', 'Get-RemoteFile', 'Get-UnicodeOfChar', 'Get-VSInstallationPath', 'Invoke-InDir', 'Kill-Process', 'Kill-Service', 'New-ProxyCommand', 'Open-Code', 'Open-Cursor', 'Open-InVisualStudio', 'Open-VisualStudioSolution', 'Out-Code', 'Restart-Process', 'Select-FileGUI', 'Select-FolderGUI', 'Set-Constant', 'Set-LocationNew', 'Show-AppWindow', 'Show-ProcessTree', 'Show-Window', 'Split-RemainParameters', 'Start-ServiceWithTimeout', 'Stop-LockingProcess', 'Test-ParameterValidateSet', 'Write-ErrorDetails')
}
