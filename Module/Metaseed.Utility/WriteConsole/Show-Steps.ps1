function Show-Steps {
  if ($__Session.Steps.Count -eq 0) {
    Write-Host "No executed steps"
    return
  }
  Write-host "`nPreious Command's Executed Steps:" -ForegroundColor DarkYellow
  $__Session.Steps | % {
    if ($_.type -eq 'Step') {
      Write-Step $_.message -replay
    }
    elseif ($_.type -eq 'SubStep') {
      Write-SubStep $_.message -replay
    }
    elseif ($_.type -eq 'Important') {
      Write-Important $_.message -replay
    }
    elseif ($_.type -eq 'Action') {
      write-action $_.message -replay
    }
  }
}

Set-Alias ss Show-Steps
Export-ModuleMember -Alias ss