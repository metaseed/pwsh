
function Git-Push {
  [CmdletBinding()]
  param (
  )
  # get local branch name
  $branch = git branch --show-current
  if($LASTEXITCODE -ne 0) {throw 'not on a branch'}

  # are the local branch already pushed to remote?
  if(Git-HasRemoteBranch)
  {
    # To push the current branch AND set the remote as upstream
    Write-Execute "git push --set-upstream origin $branch"
  } else {
    Write-Execute "git push"
  }
  Write-Execute "git status"
}

