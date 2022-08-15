@{
  RootModule = 'Metaseed.Lib.psm1'
  ModuleVersion = '1.0.1'
  AliasesToExport = @()
  CmdletsToExport = @()
  FunctionsToExport = @('Complete-Command', 'Get-AllCmdFiles', 'Get-DynCmdParam', 'Invoke-SubCommand', 'Update-Installation', 'Write-AllSubCommands')
}
