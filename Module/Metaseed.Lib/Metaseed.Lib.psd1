@{
  RootModule = 'Metaseed.Lib.psm1'
  ModuleVersion = '1.0.2'
  AliasesToExport = @()
  CmdletsToExport = @()
  FunctionsToExport = @('Get-CmdsFromCache','Find-CmdItem','Complete-Command', 'Get-AllCmdFiles', 'Get-DynCmdParam', 'Invoke-SubCommand', 'Update-Installation', 'Write-AllSubCommands')
}
