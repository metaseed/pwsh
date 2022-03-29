function Git-BranchFromLatestMaster {
  param (
    # new branch name
    [Parameter(Mandatory = $true)]
    [string]
    $BranchName
  )
  $guard = Git-SaftyGuard -noKeep 'Git-BranchFromLatestMaster'

  try {
    $current = Write-Execute 'git branch --show-current'
    if ($current -ne 'master') {
      Write-Execute 'git status'
      Write-Execute 'git checkout master'
      if ($LASTEXITCODE -ne 0) {
        Write-Error "Error when checkout master, nothing changed."
        return
      }
    }

    ## rebase master onto remote
    Write-Execute 'git pull --rebase' # the --autostash option just do git stash apply, so the staged and changed would merge into changes(no staged anymore)

    Write-Execute "git checkout -b $BranchName"
  }
  catch {
    Write-Error 'Git-BranchFromLatestMaster execution error.'
  }
  finally {
    if ($guard -eq [GitSaftyGuard]::Stashed) {
      Write-Execute 'git stash apply --index' 'restore index&tree&untracked' # --index: not merge index into worktree, the same as the state before stash
    }
  }

  Write-Execute 'git status'
}

Set-Alias gitb Git-BranchFromLatestMaster

function Git-Branch {
  git branch @args -v --sort=committerdate
}
# git config --global branch.sort -committerdate
Export-ModuleMember Git-Branch
