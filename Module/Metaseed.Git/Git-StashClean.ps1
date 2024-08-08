<#
.Synopsis
keep max cout stash and remove all the old ones
#>
function Git-StashClean {
  [CmdletBinding()]
  param(
    [int]
    $maxToKeep = 8
  )

  $list = git stash list
  $count = $list.count

  if($count -le $maxToKeep) {
    Write-Information "we only have $count in stash, nothing changed!"
    return
  }

  for ($i = 0; $i -lt ($count - $maxToKeep); $i++) {
    git stash drop $maxToKeep
  }
  write-host "current in stash:"
  git stash list
}

# gh Git-DropStash
