function Git-BranchFromLatestMaster {
  param (
    # new branch name
    [Parameter(Mandatory=$true)]
    [string]
    $BranchName
  )

  $current = Write-Execute 'git branch --show-current'
  if($current -ne 'master') {
    Write-Execute 'git status'
    Write-Execute 'git checkout master'
    if($LASTEXITCODE -ne 0) {
      Write-Error "Error when checkout master, nothing changed."
      return;
    }
  }

  Write-Execute 'git stash' 'stash index&changes'
  Write-Execute 'git pull --rebase' # the --autostash option just do git stash apply, so the staged and changed would merge into changes(no staged anymore)
  Write-Execute 'git stash apply --index' 'restore index&changes' # --index: not merge index into worktree, the same as the state before stash
  Write-Execute "git checkout -b $BranchName"
  Write-Execute 'git status'
}

New-Alias gitb Git-BranchFromLatestMaster
