@{
  ModuleVersion     = '1.0.2'
  RootModule        = 'Metaseed.Terminal.psm1'
  NestedModules     = '_bin\TerminalBackground.dll'
  Author            = 'Metaseed'
  FunctionsToExport = @('Show-WTBackgroundImage', 'Set-WTBgImg', 'Initialize-WTBgImg', 'Start-WTCyclicBgImg', 'Stop-WTCyclicBgImg')
}