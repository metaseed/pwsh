@{
  Author            = 'Metaseed'
  NestedModules     = @('_bin\Metaseed.PSUtility.dll','Metaseed.Utility.psm1')
  # RootModule = 'Metaseed.Utility.psm1'
  ModuleVersion = '1.0.5'
  AliasesToExport = @('const', 'snl')
  CmdletsToExport = @('Test-SampleCmdlet')
  FunctionsToExport = @('Breakable-Pipeline', 'Find-FromParent', 'Find-LockingProcess', 'Get-CallerVariable', 'Get-DotnetVersions', 'Get-ParentProcess', 'Get-RedirectedUrl', 'Get-RemoteFile', 'Kill-Process', 'Kill-Service', 'New-ProxyCommand', 'Select-FolderGUI', 'Set-CallerVariable', 'Set-Constant', 'Set-NewLocation', 'Stop-LockingProcess')
}
