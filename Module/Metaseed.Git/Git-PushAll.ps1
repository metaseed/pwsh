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
  git status

  if ($confirm) { Confirm-Continue }
  if (Git-HasRemoteBranch) {
    # the --autostash option just do git stash apply, so the staged and changed would merge into changes(no staged anymore)
    # so we do saftyGuard first
    Write-Execute 'git pull --rebase' 
  }
  
  Write-Execute 'git add .'
  Write-Execute "git commit -am '$message'"
  Git-Push
}

New-Alias gitp Git-PushAll

# Export-ModuleMember -Alias  gip