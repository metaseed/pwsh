function Git-PushAll {
  [CmdletBinding()]
  param (
    # commit message
    [Parameter()]
    [string]
    $message = 'ok',
    [switch]
    [alias('c')]
    $confirm
  )
  if(!(Git-HasLocalChanges)) { return}

  # gitp play-ring-when-finished works
  $message = $message -replace '-', ' '
  if ($confirm) { Confirm-Continue }
  Write-Execute 'git add -A' 'All: adds, modifies and removes index entries to match the working tree'
  Write-Execute "git commit -m '$message'" -ErrorAction SilentlyContinue

  Git-Push
}

New-Alias gitp Git-PushAll

# Export-ModuleMember -Alias  gip