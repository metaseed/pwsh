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

  Write-Execute 'git pull'
  Write-Execute "git checkout -b $BranchName"
  Write-Execute 'git status'
}
