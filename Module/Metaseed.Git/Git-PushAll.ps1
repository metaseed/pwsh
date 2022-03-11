function Git-PushAll {
  [CmdletBinding()]
  param (
    # commit message
    [Parameter(Mandatory=$true)]
    [string]
    $message
  )
  git status

  Enter-Continue
  Write-Execute 'git add .'
  Write-Execute "git commit -am '$message'"
  Git-Push
}
