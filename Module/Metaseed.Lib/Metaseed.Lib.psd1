@{
  RootModule = 'Metaseed.Lib.psm1'
  ModuleVersion = '1.0.2'
  AliasesToExport = @()
  CmdletsToExport = @()
  FunctionsToExport = @('Get-AppDynamicArgument','Complete-Command', 'Find-CmdItem', 'Get-AllCmdFiles', 'Get-CmdsFromCache', 'Get-CmdsFromCacheAutoUpdate', 'Get-DynCmdParam', 'Invoke-SubCommand', 'Update-Installation', 'Write-AllSubCommands')
}
