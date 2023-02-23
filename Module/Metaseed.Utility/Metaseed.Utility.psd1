@{
  Author            = 'Metaseed'
  NestedModules     = @('_bin\Metaseed.PSUtility.dll','Metaseed.Utility.psm1')
  # RootModule = 'Metaseed.Utility.psm1'
  ModuleVersion = '1.0.5'
  AliasesToExport = @('const', 'snl')
  CmdletsToExport = @('Get-ActiveComObject', 'Test-SampleCmdlet')
  FunctionsToExport = @('Breakable-Pipeline', 'Find-FromParent', 'Find-LockingProcess', 'Get-DotnetVersions', 'Get-ParentProcess', 'Get-RedirectedUrl', 'Get-RemoteFile', 'Kill-Process', 'Kill-Service', 'New-ProxyCommand', 'Open-InVisualStudio', 'Select-FileGUI', 'Select-FolderGUI', 'Set-Constant', 'Set-NewLocation', 'Start-ServiceWithTimeout', 'Stop-LockingProcess')
}
