function Git-RebaseMaster {
  # get local branch name
  $branch = git branch --show-current
  if ($LASTEXITCODE -ne 0) { Write-Error 'not on a branch' }

  Write-Execute "git pull --rebase"

  if ($branch -ne 'master') {
    Write-Execute 'git checkout master'
    Write-Execute 'git pull --rebase'
    Write-Execute "git checkout $branch"
    Write-Execute "git merge master"
    Write-Execute "git push"
  }

}