@{
  Author            = 'Metaseed'
  NestedModules     = @('_bin\Metaseed.PSUtility.dll','Metaseed.Utility.psm1')
  # RootModule = 'Metaseed.Utility.psm1'
  ModuleVersion = '1.0.5'
  AliasesToExport = @('const', 'sln')
  CmdletsToExport = @('Get-ActiveComObject', 'Test-SampleCmdlet')
  FunctionsToExport = @('Breakable-Pipeline', 'Find-FromParent', 'Find-LockingProcess', 'Find-PsReadlinePath', 'Get-DateFromLunar', 'Get-DotnetVersions', 'Get-ErrorDetails', 'Get-LunarDate', 'Get-ParentProcess', 'Get-ProcessTree', 'Get-RedirectedUrl', 'Get-RemoteFile', 'Get-UnicodeOfChar', 'Get-VSInstallationPath', 'Invoke-InDir', 'Kill-Process', 'Kill-Service', 'New-ProxyCommand', 'Open-InVisualStudio', 'Restart-Process', 'Select-FileGUI', 'Select-FolderGUI', 'Set-Constant', 'Set-LocationNew', 'Show-AppWindow', 'Show-ProcessTree', 'Split-RemainParameters', 'Start-ServiceWithTimeout', 'Stop-LockingProcess', 'Test-ParameterValidateSet', 'Write-ErrorDetails')
}
