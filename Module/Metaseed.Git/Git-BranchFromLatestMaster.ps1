function Git-BranchFromLatestMaster {
  param (
    # new branch name
    [Parameter(Mandatory=$true)]
    [string]
    $BranchName
  )

  $current = git branch --show-current
  if($current -ne 'master') {
    git satus
    git checkout master
  }
  git pull
  git checkout -b $BranchName
  git status
}
