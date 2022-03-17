function Write-Execute {
  param (
    [string]$command
  )
  Write-Host $command -BackgroundColor blue -ForegroundColor yellow 
  # note: if put parenthesis around: return (iex $command), the output would be no color
  # i.e. Write-Execute 'git status', if there are modification, no red text for modification files
  return iex $command
}