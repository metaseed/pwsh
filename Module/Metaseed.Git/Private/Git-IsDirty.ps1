function Git-IsDirty {
  $status = git status
  $dirtyMsg = $status -match 'modified:|Untracked files:|Your branch is ahead of'
  if ($dirtyMsg.length -gt 0) {
    Write-Warning "Your have local modification not pushed to remote`n$status`n`n"
    return $true
  }
  return $false
}