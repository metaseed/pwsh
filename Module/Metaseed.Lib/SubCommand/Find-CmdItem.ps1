function Get-CmdsFromCache([string]$cacheName, [string]$Directory, [string]$filter = '*.ps1', [switch]$update) {
  $varName = "__${cacheName}_cmds__"

  if ($update) {
    $cmds = @{}
    Get-AllCmdFiles $Directory $filter | % {
      if ($cmds[$_.BaseName]) {
        Write-Host "param: cacheName: $cacheName , dir: $Directory, filter: $filter ; update: $update"
        Write-Warning "More than one command found for '$($_.BaseName)': Omit the one in $($_.FullName), use the one in $($cmds[$_.BaseName])"
        # Exit
      }
      else {
        $cmds[$_.BaseName] = $_
      }
    }
    Set-Variable -Scope Global -Name $varName -Value $cmds
    # write-host "`n update"
    return $cmds
  }
  # -valueonly is used to return the variable value, otherwise return the variable entry
  return Get-Variable -Scope Global -Name $varName -ValueOnly -ErrorAction Ignore
}

function Get-CmdsFromCacheAutoUpdate([string]$cacheName, [string]$Directory, [string]$filter = '*.ps1') {
  $cacheValue = Get-CmdsFromCache $cacheName $Directory $filter
  if (!$cacheValue) {
    $cacheValue = Get-CmdsFromCache $cacheName $Directory $filter -update
    # Write-Host "sdddf"
  }
  return $cacheValue
}

Export-ModuleMember Get-CmdsFromCache, Get-CmdsFromCacheAutoUpdate
function Find-CmdItem {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]
    $cacheName,
    [string]
    $Directory,
    [string]$Command,
    [string]$filter = '*.ps1',
    [scriptblock]$updateScript
  )

  # dynamic global variable
  $cacheValue = Get-CmdsFromCache $cacheName $Directory $filter

  if($updateScript) {
    $update = Invoke-Command -ScriptBlock $updateScript -ArgumentList $cacheValue, $Command
  }
  if (!$cacheValue -or !$cacheValue[$Command] -or !(test-path $cacheValue[$Command]) -or $update) {
    Write-Verbose "Get-CmdsFromCache $cacheName $Directory $filter -update"
    $cacheValue = Get-CmdsFromCache $cacheName $Directory $filter -update
    # $d = "$env:temp/$((Get-Date).Millisecond).json"
    # ConvertTo-Json $cacheValue > $d
    # code $d
  }
  $file = $cacheValue[$Command]
  return $file
}

