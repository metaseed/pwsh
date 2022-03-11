function Git-SyncBranchWithRemoteMaster {
  # get local branch name
  $branch = git branch --show-current
  if ($LASTEXITCODE -ne 0) { Write-Error 'not on a branch' }

  Write-Step "git pull --rebase"
  git pull --rebase

  if ($branch -ne 'master') {
    Write-Step 'git checkout master'
    git checkout master
    Write-Step 'git pull --rebase'
    git pull --rebase
    Write-Step "git checkout $branch"
    git checkout $branch
    Write-Step "git merge master"
    git merge master
    Write-Step "git push"
    git push
  }

}