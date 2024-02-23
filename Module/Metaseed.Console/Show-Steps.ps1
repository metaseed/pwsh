<#
.NOTES
use get-error and $error to get more information about the errors
#>
function Show-Steps {
  [Alias('ss')]
  [CmdletBinding()]
  param (

  )
  if ($__PSReadLineSessionScope.Steps.Count -eq 0) {
    Write-Host "No executed steps"
    return
  }

  # update last cmd only when Steps is not empty: steps is the steps of last cmd
  if(!$__PSReadLineSessionScope.Steps.lastCmd) {
    $lastCmd = Get-History -Count 1
    $cmdLine = $lastCmd.CommandLine
    Add-Member -InputObject $__PSReadLineSessionScope.Steps -NotePropertyMembers @{lastCmd=$cmdLine}
  }

  $cmdLine = $__PSReadLineSessionScope.Steps.lastCmd
  Write-host "Preious Command: " -NoNewline
  write-host "$cmdLine" -ForegroundColor Blue
  Write-host "`nExecuted Steps:" -ForegroundColor DarkGreen
  $hasErr = $false
  $__PSReadLineSessionScope.Steps | % {
    if ($_.type -eq 'Step') {
      Write-Step $_.message -replay
    }
    elseif ($_.type -eq 'SubStep') {
      Write-SubStep $_.message -replay
    }
    elseif ($_.type -eq 'Attention') {
      Write-Attention $_.message -replay
    }
    elseif ($_.type -eq 'Action') {
      write-action $_.message -replay
    } elseif($_.type -eq 'Error') {
      WriteError $_.message -replay
      $hasErr = $true
    } elseif($_.type -eq 'Warning') {
      WriteWarning $_.message -replay
    }elseif($_.type -eq 'Notice') {
      Write-Notice $_.message -replay
    }

  }
  if($hasErr) {
    Write-Host "`n use `$error or get-error to get more information about the errors" -ForegroundColor DarkYellow
  }
}

