<#
list branches and sort by date (latest last).
current branch marked by *, add the date column before the commit message
#>
function Git-Branch {
  # note: @args not work
  #'note: -v - show commit sha and msg'
  # test @args: git-branch --merged
  # @args: Contains an array of values for undeclared parameters that are passed to a function, script, or script block
  $branches = git branch -v --sort=committerdate @args |
  # output like: jsong12/fix/config-page-load                                        9580c652eb bump version: {{release}}.0.218
  % {
    # * is the current branch,i.e:
    # * jsong12/features/api-opcua-v1                   2de5f6ed8 Merged PR 471....
    $null = $_ -match "([\*\s] [\S]+\s+)([\S]+)\s{0,1}(.*)$"
    $branchNameWithSpaces = $matches[1]
    $commitSha = $matches[2]
    $commitMsg = $matches[3]
    # with this cmd, the date is at the end of the message
    $shaAndMsg = git show -s --pretty=reference $commitSha
    # 9580c652eb (bump version: {{release}}.0.218, 2022-03-29)
    $null = $shaAndMsg -match  "^.+, (\d{4}-\d{2}-\d{2}).*$"
    $commitDate = $Matches[1]
    # write-host -ForegroundColor gray $branchNameWithSpaces -noNewLine
    # Write-Host -ForegroundColor Cyan $shaAndMsg
    return "$branchNameWithSpaces $commitDate $commitMsg"
    #  jsong12/feat/config-page-nav                                         1df27ce6fa (ok, 2022-05-06)
  }
   return $branches
}
# git config --global branch.sort -committerdate

# Git-Branch