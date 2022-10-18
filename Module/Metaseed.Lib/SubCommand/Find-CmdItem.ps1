<#
.SYNOPSIS
get commands of a folder from the cache

.DESCRIPTION
GlobalVariable <= Cache <= Disk
if GlobalVariable or Cache is null, update from disk
.EXAMPLE
An example

.NOTES
General notes
#>
function Get-CmdsFromCache {
  [CmdletBinding()]
  param([string]$cacheName, [string]$Directory, [string]$filter = '*.ps1',
  # to force update the cache and GlobalVarible from Disk
   [switch]$update)

  $varName = "__${cacheName}_cmds__"

  $cacheFile = "$env:temp\_MsPwshCache\${cacheName}.json"
  if ($update) {
    # write-host "update $cacheName"
    $cmds = @{}
    Get-AllCmdFiles $Directory $filter | % {
      if ($cmds[$_.BaseName]) {
        Write-Verbose "param: cacheName: $cacheName , dir: $Directory, filter: $filter ; update: $update"
        Write-Warning "More than one command found for '$($_.BaseName)': Omit the one in $($_.FullName), use the one in $($cmds[$_.BaseName])"
        # Exit
      }
      else {
        $cmds[$_.BaseName] = "$_"
      }
    }
    Set-Variable -Scope Global -Name $varName -Value $cmds
    if (!(test-path -PathType Container "$env:temp\_MsPwshCache")) {
      new-item -ItemType Directory -Path $env:temp\_MsPwshCache
    }
    ConvertTo-Json $cmds | Set-Content $cacheFile  -Force
    return $cmds
  }
  # -valueonly is used to return the variable value, otherwise return the variable entry
  $v = Get-Variable -Scope Global -Name $varName -ValueOnly -ErrorAction Ignore
  if (!$v) {
    if (Test-Path $cacheFile) {
      Write-Verbose "$varName load from  $cacheFile"
      $v = Get-Content -Raw $cacheFile | ConvertFrom-Json -AsHashtable # otherwise return psobject
      Set-Variable -Scope Global -Name $varName -Value $v
    }
    else {
      return Get-CmdsFromCache $cacheName $Directory $filter -update
    }
  }
  return $v
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
    [string]$filter = '*.ps1',
    [scriptblock]$updateScript
  )

  # dynamic global variable
  $cacheValue = Get-CmdsFromCache $cacheName $Directory $filter

  if ($updateScript) {
    $update = Invoke-Command -ScriptBlock $updateScript -ArgumentList $cacheValue, $Command
  }
  if (!$cacheValue[$Command] -or !(test-path $cacheValue[$Command]) -or $update) {
    Write-Verbose "$Command $update $($cacheValue[$Command])"
    Write-Verbose "Get-CmdsFromCache $cacheName $Directory $filter -update"
    $cacheValue = Get-CmdsFromCache $cacheName $Directory $filter -update
    # $d = "$env:temp/$((Get-Date).Millisecond).json"
    # ConvertTo-Json $cacheValue > $d
    # code $d
  }
  $file = $cacheValue[$Command]
  return $file
}

