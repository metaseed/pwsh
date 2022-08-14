<#
.NOTES
use get-error and $error to get more information about the errors
#>
function Show-Steps {
  if ($__PSReadLineSessionScope.Steps.Count -eq 0) {
    Write-Host "No executed steps"
    return
  }
  Write-host "`nPreious Command's Executed Steps:" -ForegroundColor DarkYellow
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

Set-Alias ss Show-Steps
Export-ModuleMember -Alias ss

