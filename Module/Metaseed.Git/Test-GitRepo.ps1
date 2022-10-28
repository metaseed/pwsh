function Test-GitRepo {
  if(git rev-parse --is-inside-work-tree 2>$null){
    return $true
  }
  return $false
  # git branch --show-current #>$null
  # if ($LASTEXITCODE -ne 0) {
  #   # Write-Error 'not under a git repository'
  #   return $false
  # }
  # return $true
  # ## another way to assert on-branch
  # git rev-parse 2>$null
  # if ($LASTEXITCODE -ne 0) {
  #   Write-Error 'No Source Branch Name. Please run this command from a git repo foler'
  #   Exit 1
  # }
}