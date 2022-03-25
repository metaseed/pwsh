function Git-HasRemoteBranch {
  git ls-remote --exit-code --heads origin $branch >$null # blackhole the output stream
  return ($LASTEXITCODE -eq 0) # local 2; remote 0
}
