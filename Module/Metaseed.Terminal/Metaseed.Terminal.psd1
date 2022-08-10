@{
  Author            = 'Metaseed'
  NestedModules     = @("_bin\TerminalBackground.dll", 'Metaseed.Terminal.psm1')
  # RootModule        = 'Metaseed.Terminal.psm1'
  ModuleVersion     = '1.0.6'
  AliasesToExport = @()
  CmdletsToExport = @('Set-WTBgImg', 'Start-WTCyclicBgImg', 'Stop-WTCyclicBgImg')
  FunctionsToExport = @('Show-WTBackgroundImage')
}
