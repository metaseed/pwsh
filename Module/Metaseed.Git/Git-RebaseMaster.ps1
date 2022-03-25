function Git-RebaseMaster {
  Git-SaftyGuard

  $branch = git branch --show-current
  ## rebase branch with remote
  if (!(Git-HasRemoteBranch)) {
    Write-Execute "git push --set-upstream origin $branch"
  }

  Write-Execute 'git stash' 'stash branch index&changes'
  Write-Execute 'git pull --rebase' # the --autostash option just do git stash apply, so the staged and changed would merge into changes(no staged anymore)
  Write-Execute 'git stash pop --index' 'restore index&changes' # --index: not merge index into worktree, the same as the state before stash

  $branch = git branch --show-current
  if ($branch -ne 'master') {
    ## rebase master with remote
    Write-Execute 'git checkout master'
    Write-Execute 'git stash' 'stash index&changes'
    Write-Execute 'git pull --rebase'
    ## rebase branch with master
    Write-Execute "git checkout $branch"
    Write-Execute "git rebase master"
    Write-Execute "git push"

    Write-Execute 'git stash pop --index' 'restore index&changes'
    Write-Execute 'git status'
  }

}