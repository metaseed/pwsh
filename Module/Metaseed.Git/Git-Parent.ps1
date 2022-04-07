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
function Git-Parent {
  [CmdletBinding()]
  Param
  (
    [Parameter(Position = 0)]
    [string] $BranchName,
    [switch] $FindAll
  )

  $pinfo = New-Object System.Diagnostics.ProcessStartInfo
  $pinfo.FileName = "git"
  $pinfo.RedirectStandardOutput = $true
  $pinfo.UseShellExecute = $false
  $pinfo.Arguments = "show-branch --current --topo-order --no-color"

  $p = New-Object System.Diagnostics.Process
  $p.StartInfo = $pinfo
  $p.Start() | Out-Null
  $stdout = $p.StandardOutput

  $currentBranchIndex = 0
  $currentBranchName = ""
  $currentBranchFound = $false
  $allBranchesListed = $false
  $foundBranch = ""

  $foundBranches = @{}

  while ( ($stdout -ne $null) -and (($line = $stdout.ReadLine()) -ne $null) ) {
    if (-not $currentBranchFound) {
      if ($BranchName -eq "") {
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
            exit -1
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
        exit -1
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
    exit -1
  }
  return $foundBranch
}