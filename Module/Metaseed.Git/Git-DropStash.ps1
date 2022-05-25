<#
.Synopsis
keep max cout stash and remove all the old ones
#>
function Git-DropStash {
  [CmdletBinding()]
  param(
    [int]
    $maxToKeep = 8
  )

  $list = git stash list
  $count = $list.count

  if($count -le $maxToKeep) {
    write-host "we only have $count in stash, nothing changed!"
    return
  }

  for ($i = 0; $i -lt ($count - $maxToKeep); $i++) {
    git stash drop $maxToKeep
  }
  "current in stash:"
  git stash list
}

# gh Git-DropStash
