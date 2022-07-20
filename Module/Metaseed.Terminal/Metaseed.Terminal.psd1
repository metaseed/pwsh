@{
  ModuleVersion     = '1.0.6'
  # RootModule        = 'Metaseed.Terminal.psm1'
  NestedModules     = @("_bin\TerminalBackground.dll", 'Metaseed.Terminal.psm1')
  Author            = 'Metaseed'
  FunctionsToExport = @('Show-WTBackgroundImage','Set-WTBgImg', 'Start-WTCyclicBgImg', 'Stop-WTCyclicBgImg')
}