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


  if ($confirm) { Confirm-Continue }
  Write-Execute 'git add -A' 'adds, modifies, and removes index entries to match the working tree'
  Write-Execute "git commit -m '$message'"

  if (Git-HasRemoteBranch) {
    Write-Execute 'git pull --rebase' 
  }

  Git-Push
}

New-Alias gitp Git-PushAll

# Export-ModuleMember -Alias  gip