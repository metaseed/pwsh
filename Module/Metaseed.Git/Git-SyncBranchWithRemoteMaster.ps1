function Git-SyncBranchWithRemoteMaster {
  # get local branch name
  $branch = git branch --show-current
  if ($LASTEXITCODE -ne 0) { Write-Error 'not on a branch' }

  Write-Host "git pull --rebase" -backgroundColor blue 
  git pull --rebase

  if ($branch -ne 'master') {
    Write-Host 'git checkout master' -backgroundColor blue 
    git checkout master
    Write-Host 'git pull --rebase' -backgroundColor blue 
    git pull --rebase
    Write-Host "git checkout $branch" -backgroundColor blue 
    git checkout $branch
    Write-Host "git merge master" -backgroundColor blue 
    git merge master
    Write-Host "git push" -backgroundColor blue 
    git push
  }

}