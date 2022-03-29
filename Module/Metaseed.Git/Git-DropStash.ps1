function Git-DropStash {
  param(
    [int]
    $start = 8
  )

  $list = git stash list
  $count = $list.count

  if($count -le $start) {
    "we only have $count in stash, nothing changed!"
    return
  }

  for ($i = 0; $i -lt ($count - $start); $i++) {
    git stash drop $start
  }
  "current in stash:"
  git stash list
}