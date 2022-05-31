function Git-HasLocalChanges {
  [CmdletBinding()]
  param ()
  $status = git status
  $dirtyMsg = $status -match 'modified:|Untracked files:|Your branch is ahead of| have diverged'
  if ($dirtyMsg.length -eq 0) {
    Write-Host "Your do not have local changes`n$status"
    return $false
  }
  return $true
}