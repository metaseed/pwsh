function Git-HasRemoteBranch {
  $branch = git branch --show-current
  if ($LASTEXITCODE -ne 0) {
    Write-Error 'not on a branch' 
    Exit 1
  }
  git ls-remote --exit-code --heads origin $branch >$null # blackhole the output stream
  return ($LASTEXITCODE -eq 0) # local 2; remote 0
}
