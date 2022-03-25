enum GitSaftyGuard { Stashed; NoNeedStach }
function Git-SaftyGuard {
  param(
    [string]
    $message,
    # not keep index&changes, remember to pop/apply:
    # Write-Execute 'git stash pop/apply --index' 'restore index&tree&untracked'
    # --index: not merge index into worktree, the same as the state before stash
    [switch]
    [Alias('nk')]
    $nokeep
  )
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
  # ## another way to assert on-branch
  # git rev-parse 2>$null
  # if ($LASTEXITCODE -ne 0) {
  #   Write-Error 'No Source Branch Name. Please run this command from a git repo foler'
  #   Exit 1
  # }

  ## keep changes for safty
  $msg = "Git-SaftyGuard$($message ? '' : ":$message")"
  $r =  Write-Execute "git stash push --include-untracked --message  $msg" 'stash keep index&tree&untracked'# --keep-index would just keep staged, the modifed is not kept in work directory.
  if ($r -eq 'No local changes to save') { return [GitSaftyGuard]::NoNeedStash }

  if (!($nokeep)) {
    Write-Execute "git stash apply --index" # the index is not merged to changes but kept in index (stage)
  }

  return [GitSaftyGuard]::Stashed
}