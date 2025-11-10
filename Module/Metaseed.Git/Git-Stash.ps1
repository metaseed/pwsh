enum GitSaftyGuard { Stashed; NoNeedStach }
<#
.DESCRIPTION
1. assert the current dir is under a git branch: on git branch
1. store changes onto stash with a message
1. restore changes if -keep is set

git pull: --autostash option just do git stash apply, so the staged and changed would merge into changes(no staged anymore), use Git-StashApply to do it
#>
function Git-Stash {
  param(
    [string]
    $message,
    # stash and then apply, also keep index during pop.
    [switch]
    [Alias('k')]
    $keep
  )

  ## assert on a branch
  if(!(Test-GitRepo)) {
    break SCRIPT
  }

  $branch = git branch --show-current
  ## keep changes for safty
  if(!$message) {
    $callStack = Get-PSCallStack
    if ($callStack.Count -gt 1) {
        $message = "from: $($callStack[1].Command)"
    }
  }
  $msg = "'Git-Stash, $message - $(Get-date) - branch:$branch'"
  # --keep-index would keep staged unsaved to stash (All changes already added to the index are left intact.).
  # here we want to save all changes, so we don't use --keep-index.
  $r = Write-Execute "git stash push --include-untracked --message  $msg" 'stash: index&tree&untracked'
  $out = 'No local changes to save'
  if ($r -eq $out) {
    Write-Attention "Git: $out"
    return [GitSaftyGuard]::NoNeedStash
  }

  if ($keep) {
    # with --index: the index is not merged to changes but kept in index (stage)
    # --index: not merge index into worktree, the same state before stash
    Write-Execute "git stash apply --index" > $null
  }

  return [GitSaftyGuard]::Stashed
}