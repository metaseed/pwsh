
<#
.SYNOPSIS
get parent process
.DESCRIPTION

#>
function Get-ParentProcess {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]$ParentProcessName = '',
    [Parameter()]
    [int]$ProcessId = -1,
    [Parameter()]
    [switch] $TopMost
  )
  if ($ProcessId -eq -1) {
    $process = [Diagnostics.Process]::GetCurrentProcess()
  }
  else {
    $process = [Diagnostics.Process]::GetProcessById($ProcessId)
  }
  $process | Format-Table | Out-String | % { Write-Verbose $_ }
  
  while ($null -ne $process.Parent) {
    $process.Parent.refresh()
    if ($process.Parent.HasExited) {
      break;
    }
    
    if('' -eq $ParentProcessName -and -not $TopMost) {
      return $process.Parent
    }
    if ($process.Parent.ProcessName -eq $ParentProcessName) {
      return $process.Parent
    }
    
    $process = $process.Parent
    $process | Format-Table | Out-String | % { Write-Verbose $_ }
  }
  if($TopMost) {return $process}
  return $null
}
