function Git-PushAll {
  [CmdletBinding()]
  param (
    # commit message
    [Parameter(Mandatory=$true)]
    [string]
    $message
  )
  git status

  Confirm-Continue
  Write-Execute 'git add .'
  Write-Execute "git commit -am '$message'"
  Git-Push
}

New-Alias gitp Git-PushAll

# Export-ModuleMember -Alias  gip