
function Git-Push {
  [CmdletBinding()]
  param (
  )
  # get local branch name
  $branch = git branch --show-current
  if($LASTEXITCODE -ne 0) {throw 'not on a branch'}

  # are the local branch already pushed to remote?
  git ls-remote --exit-code --heads origin $branch
  if($LASTEXITCODE -eq 2) # local 2; remote 0
  {
    # To push the current branch AND set the remote as upstream
    Write-Execute "git push --set-upstream origin $branch"
  } else {
    Write-Execute "git push"
  }
  Write-Execute "git status"
}

