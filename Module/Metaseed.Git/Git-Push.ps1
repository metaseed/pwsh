
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
    git push --set-upstream origin $branch
  } else {
    git push
  }
  git status
}

