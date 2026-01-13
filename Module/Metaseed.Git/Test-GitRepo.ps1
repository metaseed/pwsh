function Test-GitRepo {
  if(git branch --show-current 2>$null){
    return $true
  }
  return $false
  # git branch --show-current can get the branch name even there is no commit in the repo.(just after 'git init')
  # 'git rev-parse --is-inside-work-tree' and 'git symbolic-ref --short HEAD 2' can not, if not commit in repos
  # git branch --show-current #2>$null
  # if ($LASTEXITCODE -ne 0) {
  #   # Write-Error 'not under a git repository'
  #   return $false
  # }
  # return $true
  # ## another way to assert on-branch
  # git rev-parse 2>$null
  # if ($LASTEXITCODE -ne 0) {
  #   Write-Error 'No Source Branch Name. Please run this command from a git repo folder'
  #   Exit 1
  # }
}