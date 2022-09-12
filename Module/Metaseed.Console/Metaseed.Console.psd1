@{
  RootModule = 'Metaseed.Console.psm1'
  ModuleVersion = '1.0.1'
  AliasesToExport = @('ss', 'wab')
  CmdletsToExport = @()
  FunctionsToExport = @('Confirm-Continue', 'Show-AnsiColors256Bits', 'Show-AnsiColors8Bits', 'Show-ConsoleColors', 'Show-Steps', 'Write-Action', 'Write-Animated', 'Write-ANSIBar', 'Write-AnsiText', 'Write-Attention', 'write-error', 'Write-Execute', 'Write-FileTree', 'Write-Marquee', 'Write-Notice', 'Write-Step', 'Write-SubStep', 'Write-Typewriter', 'Write-Warning')
}
