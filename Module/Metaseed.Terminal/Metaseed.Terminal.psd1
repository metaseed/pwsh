@{
  ModuleVersion     = '1.0.6'
  CmdletsToExport = @('Set-WTBgImg','Start-WTCyclicBgImg','Stop-WTCyclicBgImg')
  # RootModule        = 'Metaseed.Terminal.psm1'
  NestedModules     = @("_bin\TerminalBackground.dll", 'Metaseed.Terminal.psm1')
  Author            = 'Metaseed'
  FunctionsToExport = @('Show-WTBackgroundImage')
}
