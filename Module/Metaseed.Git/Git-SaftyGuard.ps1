enum GitSaftyGuard { Stashed; NoNeedStach }
<#
.DESCRIPTION
1. assert on a branch
1. keep changes onto stash with a message
1. restore changes if -keep is set
#>
function Git-SaftyGuard {
  param(
    [string]
    $message,
    # not keep index&changes, remember to pop/apply:
    # git stash pop/apply --index
    # --index: not merge index into worktree, the same as the state before stash
    [switch]
    [Alias('k')]
    $keep
  )

  ## assert on a branch
  if(!(Test-GitRepo)) {
    break SCRIPT
  }

  ## keep changes for safty
  $msg = "'Git-SaftyGuard$($message ? ":$message": '') - $(Get-date) - $branch'"
  # --keep-index would keep staged (not stashed), the modifed is not kept in work directory and stashed.
  # here we want to save all changes, so we don't use --keep-index.
  $r = Write-Execute "git stash push --include-untracked --message  $msg" 'stash: index&tree&untracked'
  $out = 'No local changes to save'
  if ($r -eq $out) {
    Write-Attention $out
    return [GitSaftyGuard]::NoNeedStash 
  }

  if ($keep) {
    # with --index: the index is not merged to changes but kept in index (stage)
    Write-Execute "git stash apply --index" > $null 
  }

  return [GitSaftyGuard]::Stashed
}