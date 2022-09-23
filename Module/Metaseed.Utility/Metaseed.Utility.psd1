@{
  Author            = 'Metaseed'
  NestedModules     = @('_bin\Metaseed.PSUtility.dll','Metaseed.Utility.psm1')
  # RootModule = 'Metaseed.Utility.psm1'
  ModuleVersion = '1.0.5'
  AliasesToExport = @('const', 'snl')
  CmdletsToExport = @('Test-SampleCmdlet')
  FunctionsToExport = @('Breakable-Pipeline', 'Find-FromParent', 'Find-LockingProcess', 'Get-DotnetVersions', 'Get-ParentProcess', 'Get-RedirectedUrl', 'Get-RemoteFile', 'Get-VariableOutModule', 'Kill-Process', 'Kill-Service', 'New-ProxyCommand', 'Select-FolderGUI', 'Set-Constant', 'Set-NewLocation', 'Set-VariableOutModule', 'Stop-LockingProcess')
}
