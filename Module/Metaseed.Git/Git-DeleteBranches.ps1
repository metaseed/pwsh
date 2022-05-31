function Git-DeleteBranches {
  [CmdletBinding()]
  param (
    # only delete merged branch
    [Parameter()]
    [boolean]
    $merged = $false,
    # branches to keep, current branch is always kept.
    [Parameter()]
    [string[]]
    $branchesToKeep = @('master', 'main', 'development'),
    [switch]
    [Alias('kr')]
    $KeepRemote

  )

  Git-SaftyGuard 'Git-DeleteAllLocalBranches' -keep
  # if your branches names contains non ascii characters
  # [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

  ## list branches
  $filter = "^(?!.*($($branchesToKeep -join '|')|\*)).*$"
  $branches = git branch "$($merged ?'--merged': '')" | 
  # ^(?!.*(master|main|\*)).*$
  # filter out branches contains 'master' or 'main' and the current branche (marked by *)
  # note: if just filter out current: '^[^\*].*'
  Select-String -Pattern $filter

  if ($branches.Length -eq 0) {
    Write-Host "Filter: $filter`nNo Branch to Delete!`nbranches available:" -ForegroundColor yellow
    git branch
    return
  }

  Write-Warning "`n$($branches -join "`n")"
  Write-Host "`nDelete these brancheds?"
  Confirm-Continue

  $branches |
  % { 
    $branch = $_.ToString().Trim();
    git branch $($merged ? '-d': '-D') $branch
    if (-not $KeepRemote) {
      # Pushing to delete remote branches also removes remote-tracking branches
      git push origin -d "$branch"
    }
    # just delete remote tracking:
    #   git branch --delete --remotes "origin/$branch"
  }
  # Delete multiple obsolete remote-tracking branches
  git fetch origin --prune
  Write-Execute "git branch"
}