function Git-NewBranch {
  [CmdletBinding()]
  [alias('gitb')]
  param (
    # new branch name
    [Parameter(Mandatory = $true)]
    [string]
    $BranchName,
    # parent branch name, current parent branch is not set
    [Parameter()]
    [string]
    $ParentBranchName = 'master'
  )

  Git-StashPushApply {
    Write-Execute 'git status'

    $current = Write-Execute 'git branch --show-current'
    if ($current -ne $ParentBranchName) {
      Write-Execute "git checkout $ParentBranchName"
      if ($LASTEXITCODE -ne 0) {
        Write-Error "Error when checkout $ParentBranchName, nothing changed."
        return
      }
    }

    # removes references to remote branches that no longer exist on the remote repository (origin)
    # Write-Execute 'git remote prune origin' # use --prune in pull
    ## rebase master onto remote
    Write-Execute 'git pull --prune' #  --rebase

    Write-Execute "git checkout -b $BranchName"
  }
}
