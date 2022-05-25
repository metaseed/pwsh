enum GitSaftyGuard { Stashed; NoNeedStach }
function Git-SaftyGuard {
  param(
    [string]
    $message,
    # not keep index&changes, remember to pop/apply:
    # git stash pop/apply --index
    # --index: not merge index into worktree, the same as the state before stash
    [switch]
    [Alias('nk')]
    $nokeep
  )

  ## assert on a branch
  $branch = git branch --show-current #>$null
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
  $msg = "'Git-SaftyGuard$($message ? ":$message": '') - $(Get-date) - $branch'"
  # --keep-index would keep staged (not stashed), the modifed is not kept in work directory and stashed.
  # here we want to save all changes, so we don't use --keep-index.
  $r = Write-Execute "git stash push --include-untracked --message  $msg" 'stash: index&tree&untracked'
  $out='No local changes to save'
  if ($r -eq $out) {
    Write-Host $out -ForegroundColor Green
    return [GitSaftyGuard]::NoNeedStash 
  }

  if (!($nokeep)) {
    # with --index: the index is not merged to changes but kept in index (stage)
    Write-Execute "git stash apply --index" > $null 
  }

  return [GitSaftyGuard]::Stashed
}