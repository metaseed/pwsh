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
  if(!Git-HasLocalChanges) { return}


  if ($confirm) { Confirm-Continue }
  Write-Execute 'git add -A'
  Write-Execute "git commit -m '$message'"

  if (Git-HasRemoteBranch) {
    # the --autostash option just do git stash apply, so the staged and changed would merge into changes(no staged anymore)
    # so we do saftyGuard first
    Write-Execute 'git pull --rebase' 
  }
  
  Git-Push
}

New-Alias gitp Git-PushAll

# Export-ModuleMember -Alias  gip