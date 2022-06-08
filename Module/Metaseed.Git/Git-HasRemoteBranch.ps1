function Git-HasRemoteBranch {
  $branch = git branch --show-current
  if ($LASTEXITCODE -ne 0) {
    Write-Error 'not on a branch' 
    break SCRIPT
  }
  # --exit-code:
  # Exit with status "2" when no matching refs are found in the remote repository. Usually the command exits with status "0" to indicate it successfully talked with the remote repository, whether it found any matching refs.
  git ls-remote --exit-code --heads origin $branch >$null # blackhole the output stream
  return ($LASTEXITCODE -eq 0) # local 2; remote 0
}
