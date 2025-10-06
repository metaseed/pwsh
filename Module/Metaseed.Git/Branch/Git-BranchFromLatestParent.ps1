function Git-BranchFromLatestParent {
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
  $guard = Git-SaftyGuard 'Git-BranchFromLatestParent'

  Write-Execute 'git status'

  try {
    $current = Write-Execute 'git branch --show-current'
    if ($current -ne $ParentBranchName) {
      Write-Execute "git checkout $ParentBranchName"
      if ($LASTEXITCODE -ne 0) {
        Write-Error "Error when checkout $ParentBranchName, nothing changed."
        return
      }
    }

    #  remove any old, conflicting branches
    Write-Execute 'git remote prune origin'
    ## rebase master onto remote
    # the --autostash option just do git stash apply, so the staged and changed would merge into changes(no staged anymore), use Git-StashApply to do it
    Write-Execute 'git pull' #  --rebase

    Write-Execute "git checkout -b $BranchName"
  }
  catch {
    Write-Error 'Git-BranchFromLatestParent execution error.'
  }
  finally {
    if ($guard -eq [GitSaftyGuard]::Stashed) {
      # --index: not merge index into worktree, the same as the state before stash
      Write-Execute 'git stash apply --index' 'restore index&tree&untracked'
    }
    else {
      Write-Execute 'git status'

    }
  }

}
