function Git-RebaseMaster {
  $guard = Git-SaftyGuard 'Git-RebaseMaster' -noKeep

  try {
    ## rebase branch with remote
    if (Git-HasRemoteBranch) {
      # the --autostash option just do git stash apply, so the staged and changed would merge into changes(no staged anymore)
      # so we do saftyGuard first
      Write-Execute 'git pull --rebase' 
    }

    $branch = git branch --show-current
    if ($branch -ne 'master') {
      Write-Step 'rebase master with remote'
      Write-Execute 'git checkout master'
      Write-Execute 'git pull --rebase'
      Write-Step 'rebase branch with master'
      Write-Execute "git checkout $branch"
      Write-Execute "git rebase master"
      Write-Execute "git-push"
    }
  }
  catch {
    Write-Error 'Git-RebaseMaster execution error.'
  }
  finally {
    if ($guard -eq [GitSaftyGuard]::Stashed) {
      Write-Execute 'git stash apply --index' 'restore index&tree&untracked' # --index: not merge index into worktree, the same as the state before stash
    }
  }
  Write-Execute 'git status'

}