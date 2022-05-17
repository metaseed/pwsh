function Git-HasLocalChanges {
  [CmdletBinding()]
  param ()
  $status = git status
  $dirtyMsg = $status -match 'modified:|Untracked files:|Your branch is ahead of'
  if ($dirtyMsg.length -eq 0) {
    Write-Host "Your do not have local changes`n$status`n`n"
    return $false
  }
  return $true
}