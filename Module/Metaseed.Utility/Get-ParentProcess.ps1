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
  Param($id)
  # ([String] $program)
  # $process = Get-Process -Name $program
  # #get the process id of the given process
  # $id = $process.Id
  #Obtain The parent process id.
  $instance = Get-CimInstance  Win32_Process -Filter "ProcessId = '$id'"
  $instance.ParentProcessId
  #Fetch the process with the parentprocess id.
  $parentProcess = Get-Process -Id $instance.ParentProcessId
  $parentProcess
}