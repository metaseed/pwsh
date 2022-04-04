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

  Write-Execute 'git pull --rebase' 
  Write-Execute 'git add .'
  Write-Execute "git commit -am '$message'"
  Git-Push
}

New-Alias gitp Git-PushAll

# Export-ModuleMember -Alias  gip