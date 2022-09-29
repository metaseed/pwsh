@{
  RootModule = 'Metaseed.Lib.psm1'
  ModuleVersion = '1.0.2'
  AliasesToExport = @()
  CmdletsToExport = @()
  FunctionsToExport = @('Complete-Command', 'Find-CmdItem', 'Get-AllCmdFiles', 'Get-AppDynamicArgument', 'Get-CmdsFromCache', 'Get-CmdsFromCacheAutoUpdate', 'Get-DynCmdParam', 'Invoke-SubCommand', 'New-DynamicParam', 'Test-Update', 'Test-WordToComplete', 'Update-Installation', 'Write-AllSubCommands')
  VariablesToExport = @('SpecialChar')
}
