function Git-PushAll {
  [CmdletBinding()]
  param (
    # commit message
    [Parameter(Mandatory = $true)]
    [string]
    $message,
    [switch]
    [alias('c')]
    $confirm
  )
  if(!(Git-HasLocalChanges)) { return}

  # gitp play-ring-when-finished works
  $message = $message -replace '-', ' '
  if ($confirm) { Confirm-Continue }
  Write-Execute 'git add -A' 'adds, modifies, and removes index entries to match the working tree'
  Write-Execute "git commit -m '$message'" 

  Git-Push
}

New-Alias gitp Git-PushAll

# Export-ModuleMember -Alias  gip