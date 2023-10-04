function Remove-EmptyDirectory {
  [CmdletBinding()]
  param (
    [string]$topDirectory = '.',
    [switch]$Force
  )

  Get-ChildItem $topDirectory -Recurse -Force:$Force -Directory |
  Sort-Object -Property FullName -Descending |
  Where-Object { $($_ | Get-ChildItem -Force | Select-Object -First 1).Count -eq 0 } |
  Remove-Item -Verbose


  # Get-ChildItem $topDirectory -Recurse -Directory -Force:$Force | ? { -Not ($_.EnumerateFiles('*',1) | Select-Object -First 1) } | Remove-Item -Recurse
}
