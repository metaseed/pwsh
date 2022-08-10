@{
  RootModule        = 'Metaseed.VM.psm1'
  ModuleVersion     = '1.0.0'
  AliasesToExport = @('Export-VMCheckpoint', 'Get-VMCheckpoint', 'gvm', 'gvmr', 'gvmrs', 'mvmr', 'Remove-VMCheckpoint', 'Rename-VMCheckpoint', 'Restore-VMCheckpoint', 'savm', 'spvm')
  CmdletsToExport = @()
  FunctionsToExport = @('Connect-VM')
}
