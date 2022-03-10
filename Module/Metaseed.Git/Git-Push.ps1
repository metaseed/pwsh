
function Git-Push {
  [CmdletBinding()]
  param (
  )
  # get local branch name

  Write-Step "git branch --show-current"
  $branch = git branch --show-current
  if($LASTEXITCODE -ne 0) {throw 'not on a branch'}

  # are the local branch already pushed to remote?
  Write-Step "git ls-remote --exit-code --heads origin $branch"
  git ls-remote --exit-code --heads origin $branch
  if($LASTEXITCODE -eq 2) # local 2; remote 0
  {
    # To push the current branch AND set the remote as upstream
    Write-Step "git push --set-upstream origin $branch"
    git push --set-upstream origin $branch
  } else {
    Write-Step "git push"
    git push
  }
  git status
}

