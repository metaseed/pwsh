$localFile = "$__RootFolder/.local"
if (Test-Path $localFile) {
  Write-Host "find .local file in root dir, stop update!" -ForegroundColor red 
  return
}

Set-ExecutionPolicy Bypass -Scope Process -Force;
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
# (New-Object Net.WebClient).DownloadString('https://pwsh.page.link/0')|iex
iwr -useb https://pwsh.page.link/0 |iex