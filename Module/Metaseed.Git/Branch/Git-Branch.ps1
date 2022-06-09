function Git-Branch {
  # note: @args not work
  #'note: -v - show commit sha and msg'
  # test @args: git-branch --merged
  # @args: Contains an array of values for undeclared parameters that are passed to a function, script, or script block
  $branches = git branch -v --sort=committerdate @args |
  # output like: jsong12/fix/config-page-load                                        9580c652eb bump version: {{release}}.0.218
  % {
    # * is the current branch
    $null = $_ -match "([\*,\s] [\S]+\s+)([\S]+)\s{0,1}(.*)$"
    $branchNameWithSpaces = $matches[1]
    $commitSha = $matches[2]
    # $commitMsg = $matches[3]
    $shaAndMsg = git show -s --pretty=reference $commitSha
    # 9580c652eb (bump version: {{release}}.0.218, 2022-03-29)
    return "$branchNameWithSpaces $shaAndMsg"
    #  jsong12/feat/config-page-nav                                         1df27ce6fa (ok, 2022-05-06)
  }
  return $branches
}
# git config --global branch.sort -committerdate
 