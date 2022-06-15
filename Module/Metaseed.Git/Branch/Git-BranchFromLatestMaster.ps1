function Git-BranchFromLatestMaster {
  param (
    # new branch name
    [Parameter(Mandatory = $true)]
    [string]
    $BranchName
  )
  $guard = Git-SaftyGuard 'Git-BranchFromLatestMaster'

  Write-Execute 'git status'

  try {
    $current = Write-Execute 'git branch --show-current'
    if ($current -ne 'master') {
      Write-Execute 'git checkout master'
      if ($LASTEXITCODE -ne 0) {
        Write-Error "Error when checkout master, nothing changed."
        return
      }
    }

    #  remove any old, conflicting branches
    Write-Execute 'git remote prune origin'
    ## rebase master onto remote
    # the --autostash option just do git stash apply, so the staged and changed would merge into changes(no staged anymore), use Git-StashApply to do it
    Write-Execute 'git pull --rebase' 

    Write-Execute "git checkout -b $BranchName"
  }
  catch {
    Write-Error 'Git-BranchFromLatestMaster execution error.'
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

Set-Alias gitb Git-BranchFromLatestMaster

