function Git-SetParent {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string]$ParentBranchName,
    [Parameter()]
    [string]$BranchName = (git branch --show-current)
  )
  git config "branch.$BranchName.parent" "$ParentBranchName"
}