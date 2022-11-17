function Start-ExplorerInAdmin {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]
    $path = '.'
  )
  Assert-Admin

  @(Test-ProcessElevated (gps explorer)) |
  ? { !$_ }
| % {
    Write-Verbose 'restart and make the explorer run in admin mode'
    spps -n explorer;
    explorer.exe /nouaccheck "`"$path`""
    return
  }

  start $path
}

Set-Alias st Start-ExplorerInAdmin