function Git-DeleteAllLocalBranches {
  [CmdletBinding()]
  param (
    # only delete merged branch
    [Parameter()]
    [boolean]
    $merged = $false,
    # branches to keep, current branch is always kept.
    [Parameter()]
    [string[]]
    $branchesToKeep = @('master', 'main', 'development')

  )

  Git-SaftyGuard 'Git-DeleteAllLocalBranches'
  # if your branches names contains non ascii characters
  # [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

  ## list branches
  $filter = "^(?!.*($($branchesToKeep -join '|')|\*)).*$"
  $branches = git branch "$($merged ?'--merged': '')" | 
  # ^(?!.*(master|main|\*)).*$
  # filter out branches contains 'master' or 'main' and the current branche (marked by *)
  # note: if just filter out current: '^[^\*].*'
  Select-String -Pattern $filter

  if($branches.Length -eq 0) {
    Write-Host "Filter: $filter`nNo Branch to Delete!`nbranches available:" -ForegroundColor yellow
    git branch
    return
  }

  Write-Warning "`n$($branches -join "`n")"
  Write-Host "`nDelete these brancheds?"
  Confirm-Continue

  $branches |
  % { 
 
    git branch $($merged ? '-d': '-D') $_.ToString().Trim() 
  }
  Write-Execute "git branch"
}