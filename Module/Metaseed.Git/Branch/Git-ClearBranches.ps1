function Git-ClearBranches {
  [CmdletBinding()]
  param (
    [Parameter()]
    [int] $BranchesToKeep = 8,
    # branches to keep, current branch is always kept.
    [Parameter()]
    [string[]]
    $BranchesToFilterOut = @('master', 'main', 'development'),

    # only delete merged branch
    [Parameter()]
    [switch]
    $merged,

    [switch]
    [Alias('kr')]
    $KeepRemote

  )

  Git-SaftyGuard 'Git-DeleteLocalBranches' -keep
  # if your branches names contains non ascii characters
  # [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

  ## list branches
  ## not contains regex search: "^(?!.*(a|b|c)).*$"
  $filter = "^(?!\s*\S*($($BranchesToFilterOut -join '|')|\*)\s+).*$"
  $branches = git-branch "$($merged ?'--merged': '')"  | 
  # ^(?!.*(master|main|\*)).*$
  # filter out branches contains 'master' or 'main' and the current branche (marked by *)
  # note: if just filter out current: '^[^\*].*'
  Select-String -Pattern $filter

  $toRemove = $branches.Length - $BranchesToKeep
  if($toRemove -le 0) {
    Write-Host "`nNo Enough Branch to Delete! branches available: $($branches.Length -1)`n but branches to keep on parameter:$($BranchesToKeep) " -ForegroundColor yellow
    Write-Execute "git-branch"
    return
  }

  $branches = $branches[0..$toRemove]

  Write-Warning "Branches to Delete:`n$($branches -join "`n")"
  Write-Host "`nDelete these brancheds?"
  Confirm-Continue

  $branches |
  % {
    $null = $_ -match "[\*,\s] ([\S]+)\s+([\S]+)\s{0,1}(.*)$"
    $branch = $matches[1]
    git branch $($merged ? '-d': '-D') $branch
    if (-not $KeepRemote) {
      # Pushing to delete remote branches also removes remote-tracking branches
      git push origin -d "$branch"
    }
    # just delete remote tracking:
    #   git branch --delete --remotes "origin/$branch"
  }
  # Delete multiple obsolete remote-tracking branches locally
  git fetch origin --prune
  Write-Execute "git-branch" -message 'Available  branches:'
}