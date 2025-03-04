function Open-InVisualStudio {
  [CmdletBinding()]
  param (
    # file name
    [Parameter()]
    [string]
    $FilePath,
    # line
    [Parameter()]
    [int]
    $Line,
    # column
    [Parameter()]
    [int]
    $Column
  )

  if(!(Test-Path $FilePath)) {
    write-error "no such file: $FilePath"
    return
  }
  # this only work in dotnet framework, not in dotnetcore
  # so create our own
  # $dteType = [System.Type]::GetTypeFromProgID("VisualStudio.DTE.17.0", $true)
  # $dte = [System.Activator]::CreateInstance($dteType, $true)
  try {
    $dte = Get-ActiveComObject  VisualStudio.DTE # VisualStudio.DTE.17.0
  }
  catch {
  }
  if (!$dte) {
    Write-Verbose 'create new instance'
    $dte = New-Object -ComObject VisualStudio.DTE
  }

  $dte.MainWindow.Activate()
  $dte.MainWindow.Visible = $True
  $dte.UserControl = $True

  $wsShell = New-Object -ComObject WScript.Shell
  [void]$wsShell.AppActivate($dte.MainWindow.Caption)

  $dte.ItemOperations.OpenFile($FilePath) > $null
  $dte.ActiveDocument.Selection.MoveToLineAndOffset($line, $column + 1)
}

# Open-InVisualStudio 'C:\repos\SLB\_planck\planck\acquisition-opcua-plugin\src\OpcUa.Plugin\Services\Config\OpcUaConfigService.cs' 2 3