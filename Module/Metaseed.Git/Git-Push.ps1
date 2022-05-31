
function Git-Push {
  [CmdletBinding()]
  param (
  )
  # get local branch name
  $branch = git branch --show-current
  if ($LASTEXITCODE -ne 0) { throw 'not on a branch' }

  # are the local branch already pushed to remote?
  if (Git-HasRemoteBranch) {
    # Write-Execute "git push" 
    Write-Execute { git push } -noThrow -noStop #2>&1
    if ($LASTEXITCODE -ne 0) {
      Write-Execute {git pull --rebase; git push}
    }
  }
  else {
    # To push the current branch AND set the remote as upstream
    Write-Execute "git push --set-upstream origin $branch"
  }
  Write-Execute "git status"
}
