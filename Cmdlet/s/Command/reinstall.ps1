$localFile = "$__RootFolder/.git"
if (Test-Path $localFile -type Container) {
  Write-Host "find we are in the cloned git, will pull the latest code!" -ForegroundColor Yellow
  Push-Location $__RootFolder
  git pull
  Pop-Location
  return
}

Set-ExecutionPolicy Bypass -Scope Process -Force;
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
# (New-Object Net.WebClient).DownloadString('https://pwsh.page.link/0')|iex
iwr -useb https://pwsh.page.link/0 |iex # install.ps1