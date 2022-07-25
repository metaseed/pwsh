@{
  # RootModule = 'Metaseed.Utility.psm1'
  ModuleVersion = '1.0.5'
  CmdletsToExport = @('Test-SampleCmdlet')
  FunctionsToExport = @('Breakable-Pipeline', 'Find-FromParent', 'Find-LockingProcess', 'Get-DotnetVersions', 'Get-ParentProcess', 'Get-RedirectedUrl', 'Get-RemoteFile', 'Kill-Process', 'Kill-Service', 'New-ProxyCommand', 'Set-NewLocation', 'Stop-LockingProcess')
  NestedModules     = @('_bin\Metaseed.PSUtility.dll','Metaseed.Utility.psm1')
  Author            = 'Metaseed'
}
