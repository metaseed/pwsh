function Git-PushAll {
  [CmdletBinding()]
  param (
    # commit message
    [Parameter(Mandatory=$true)]
    [string]
    $message
  )
  git status
  Write-Step 'git add .'
  git add .
  Write-Step "git commit -am '$message'"
  git commit -am $message
  Git-Push
}