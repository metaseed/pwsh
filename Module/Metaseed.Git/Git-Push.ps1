
function Git-Push {
  [CmdletBinding()]
  param (
  )
  $branch = git branch --show-current
  if($LASTEXITCODE -ne 1) {throw 'not on a branch'}

  git ls-remote --exit-code --heads origin $branch
  if($LASTEXITCODE -eq 2) # local 2; remote 0
  {
    # To push the current branch AND set the remote as upstream
    git push --set-upstream origin $branch
  } else {
    git push
  }
}

