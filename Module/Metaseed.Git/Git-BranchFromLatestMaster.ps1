function Git-BranchFromLatestMaster {
  param (
    # new branch name
    [Parameter(Mandatory=$true)]
    [string]
    $BranchName
  )

  $current = Write-Execute 'git branch --show-current'
  if($current -ne 'master') {
    Write-Execute 'git satus'
    Write-Execute 'git checkout master'
  }
  Write-Execute 'git pull'
  Write-Execute "git checkout -b $BranchName"
  Write-Execute 'git status'
}
