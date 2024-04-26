# https://stackoverflow.com/questions/3161204/how-to-find-the-nearest-parent-of-a-git-branch/26597219#answer-17843908
function Git-Parent {
  [CmdletBinding()]
  param(
    $CurrentBranchName = (git branch --show-current) # the same: git rev-parse --abbrev-ref HEAD
  )
  git show-branch -a --current --topo-order --no-color |
  # Ancestors of the current commit are indicated by a star. Filter out everything else
  # we want only lines that begin with an asterisk  '^[^\[]*\*'
  Select-String '^\*' |
  # Ignore all the commits(contain the current branch name) in the current branch.
  # note: .*? no gredy match any to the first ]
  Select-String -NotMatch -Pattern "\[$([Regex]::Escape($CurrentBranchName)).*?\]" |
  # The first result will be the nearest ancestor branch. Ignore the other results
  Select-Object -First 1 |
  # just the part of the line between [], it's branch name
  # .+?\[ none gredy more than one char to [
  Foreach-Object { $_ -replace '^.+?\[(.+)\].+$', '$1' }|
  # Sometimes the branch name will include a ~# or ^# to indicate how many commits are between the referenced commit and the branch tip. We don't care. Ignore them.
  # and with any relative refs (^, ~n) removed
  Foreach-Object { $_ -replace '[\^~][0-9]*', '' }
}
# sl C:\repos\SLB\_planck\planck\
# git-parent
<#
.SYNOPSIS
    Find the "parent" branch of the current branch.

.PARAMETER BranchName
    If provided, will search for `BranchName` instead of the current branch in the repo.

.PARAMETER FindAll
    Provide the list of all parent and found grandparent branches. Otherwise it will only find the immediate parent.

.DESCRIPTION
    This script is not fool-proof as it's mostly a guess since Git doesn't really know the difference between parent and children branches. It uses "git show-branch", so it will use whatever short name the command decides to name a commit to compute which one is the parent branch.
#>
function Git-Parent_notused_complex_to_read {
  [CmdletBinding()]
  Param
  (
    [Parameter(Position = 0)]
    [string] $BranchName,
    [switch] $FindAll
  )

  ## run: git show-branch --current --topo-order --no-color
  $pinfo = New-Object Diagnostics.ProcessStartInfo
  $pinfo.FileName = "git"
  $pinfo.RedirectStandardOutput = $true
  $pinfo.UseShellExecute = $false
  $pinfo.Arguments = "show-branch --current --topo-order --no-color"

  $p = New-Object Diagnostics.Process
  $p.StartInfo = $pinfo
  $p.Start() | Out-Null
  $stdout = $p.StandardOutput

  $currentBranchIndex = 0
  $currentBranchName = ""
  $currentBranchFound = $false
  $allBranchesListed = $false
  $foundBranch = ""

  $foundBranches = @{}

  while ( ($null -ne $stdout) -and ($null -ne ($line = $stdout.ReadLine())) ) {
    if (-not $currentBranchFound) {
      if ('' -eq $BranchName) {
        if ($line.Length -gt $currentBranchIndex -and $line[$currentBranchIndex] -eq '*') {
          $currentBranchFound = $true
          # 1) Branch names can contain ']', but not spaces, and the string pattern here is "[<branch_name>] <description>", so search for "] " which will guarantee we find the delimiter rather than part of a branch name.
          # 2) Use non-greedy (.*?) matching so that commit descriptions that contain "] " wouldn't mess up the search.
          if ($line -match '\[(.*?)\] ') {
            $currentBranchName = $Matches[1]
          }
          else {
            Write-Host "Error: Couldn't parse current branch info from Git"
            $stdout.Close()
            if (-not $p.HasExited) {
              $p.Kill()
            }
            throw -1
          }
        }
        else {
          $currentBranchIndex += 1
        }
      }
      else {
        if ($line -match '\[(.*?)\] ' -and $Matches[1] -eq $BranchName) {
          $currentBranchName = $BranchName
          $currentBranchFound = $true
        }
        else {
          $currentBranchIndex += 1
        }
      }
    }

    if ($line -match '^-*$') {
      if (-not $currentBranchFound) {
        Write-Host "Couldn't find the current branch."
        $stdout.Close()
        if (-not $p.HasExited) {
          $p.Kill()
        }
        throw -1
      }
      $allBranchesListed = $true
    }
    elseif ($allBranchesListed) {
      if ($line[$currentBranchIndex] -ne ' ') {
        if ($line -match '\[(.*?)(\] |~|\^)') {
          $lineBranch = $Matches[1]
          if ($lineBranch -ne $currentBranchName) {
            $foundBranch = $lineBranch

            if (-not $foundBranches[$foundBranch]) {
              $foundBranches[$foundBranch] = $true
              #Write-Host $foundBranch
              if (-not $FindAll) {
                break
              }
            }
          }
        }
      }
    }
  }

  $stdout.Close()
  if (-not $p.HasExited) {
    $p.Kill()
  }

  if ($foundBranch -eq "") {
    Write-Host "Couldn't find parent branch."
    throw -1
  }
  return $foundBranch
}