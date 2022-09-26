$localFile = "$__RootFolder/.git"

if (Test-Path $localFile -type Container) {
  $repoParentFolder = Split-Path $__RootFolder
  Write-Host "repo's parent folder: $repoParentFolder"
  "& {$(iwr https://pwsh.page.link/dev)} $repoParentFolder" |iex
  return
}


Set-ExecutionPolicy Bypass -Scope Process -Force;
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
# (New-Object Net.WebClient).DownloadString('https://pwsh.page.link/0')|iex
iwr -useb https://pwsh.page.link/0 |iex # install.ps1