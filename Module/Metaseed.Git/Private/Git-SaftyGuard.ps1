function Git-SaftyGuard {
  <#
  .SYNOPSIS
  assert on a branch and stash index&changes&untracked
  #>
  ## assert on a branch
  git branch --show-current
  if ($LASTEXITCODE -ne 0) {
    Write-Error 'not on a branch' 
    Exit 1
  }

  ## keep changes for safty
  git stash push --include-untracked --message 'Git-RebaseMaster safty' # --keep-index would just keep staged, the modifed is not kept in work directory.
  git stash apply --index # the index is not merged to changes but kept in index (stage)
}