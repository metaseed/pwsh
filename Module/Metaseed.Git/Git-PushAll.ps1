function Git-PushAll {
  [CmdletBinding()]
  param (
    # commit message
    [Parameter(Mandatory=$true)]
    [string]
    $message
  )
  Write-Host 'git add .' -BackgroundColor blue
  git add .
  ''
  "git commit -am $message"
  git commit -am $message
  Git-Push


}