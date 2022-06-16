<#
.SYNOPSIS
This script can be used to display parent process name of a process.
.DESCRIPTION
This script can be used to display parent process name of a process.
.EXAMPLE
C:\PS> C:\Script\Parent_Process.ps1 taskhost.
Displays the parent process name of taskhost.
#>
function Get-ParentProcess {
  [CmdletBinding()]
  Param($id)
  # ([String] $program)
  # $process = Get-Process -Name $program
  # #get the process id of the given process
  # $id = $process.Id
  #Obtain The parent process id.
  $instance = Get-CimInstance Win32_Process -Filter "ProcessId = '$id'"
  $instance.ParentProcessId
  #Fetch the process with the parentprocess id.
  $parentProcess = Get-Process -Id $instance.ParentProcessId
  $parentProcess
}


function Get-ParentProcessByName {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$processName
  )
  
  $process = [System.Diagnostics.Process]::GetCurrentProcess()
  $process |Format-Table | Out-String|%{ Write-Verbose $_}
  while ($null -ne $process.Parent) {
    $process.Parent.refresh()
    if ($process.Parent.HasExited) {
      break;
    }

    if ($process.Parent.ProcessName -eq $processName) {

      return $process.Parent
    }

    $process = $process.Parent
  }
  return $null
}

Export-ModuleMember -Function Get-ParentProcessByName