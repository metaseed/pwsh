function Get-CmdsFromCache([string]$cacheName, [string]$Directory,[string]$filter = '*.ps1', [switch]$update) {
  $varName = "__${cacheName}_cmds__"

  if ($update) {
    $cmds = @{}
    Get-AllCmdFiles $Directory $filter | % {
      $cmds[$_.BaseName] = $_
    }
    Set-Variable -Scope Global -Name $varName -Value $cmds
    return $cmds
  }
  # -valueonly is used to return the variable value, otherwise return the variable entry
  return Get-Variable -Scope Global -Name $varName -ValueOnly -ErrorAction Ignore
}

Export-ModuleMember Get-CmdsFromCache
function Find-CmdItem {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]
    $cacheName,
    [string]
    $Directory,
    [string]$Command,
    [string]$filter = '*.ps1'
  )

  # dynamic global variable
  $cacheValue = Get-CmdsFromCache $cacheName $Directory $filter
  if (!$cacheValue -or !$cacheValue[$Command]) {
    $cacheValue = Get-CmdsFromCache $cacheName $Directory $filter -update
  }

  $file = $cacheValue[$Command]
  return $file
}

