function Write-Execute {
  param (
    [string]$command
  )
  Write-Host $command -BackgroundColor blue -ForegroundColor yellow 
  return (iex $command)
}