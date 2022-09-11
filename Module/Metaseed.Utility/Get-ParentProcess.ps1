
<#
.SYNOPSIS
get parent process
.DESCRIPTION

.Example
# get current process's direct parent
Get-ParentProcess
# get process 123(id)'s direct parent
Get-ParentProcess -ProcessId 123

# get current's topmost parent process, whose parent process id is null
Get-ParentProcess -Topmost

#>
function Get-ParentProcess {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]$ParentProcessName = '',
    # start from this process, -1: current process (shell)
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

    # the first parent process
    if('' -eq $ParentProcessName -and -not $TopMost) {
      return $process.Parent
    }
    # first parent process of the name
    if ($process.Parent.ProcessName -eq $ParentProcessName) {
      return $process.Parent
    }

    $process = $process.Parent
    $process | Format-Table | Out-String | % { Write-Verbose $_ }
  }

  if($TopMost) {return $process}

  return $null
}
