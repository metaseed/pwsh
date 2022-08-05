# 1. on vm: `stop-computer`
# 1. enable nested virtualization, on host: Set-VMProcessor -VMName 'win11' -ExposeVirtualizationExtensions $true
if! (gcm docker -ErrorAction SilentlyContinue)) {
  iwr https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe -OutFile $env:temp/docker.exe 
  Start-Process "$env:temp/docker.exe" -Wait @('install', '--accept-license', '--backend=wsl-2')
  # tps://wsluporustrragm/quostcors/1584710/neckwr-blo-2-in_talateion-im-incomplete
  # https://docs.microsoft.com/en-us/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package
  # Download the Linux kernel update package
  iwr https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile $env:temp/wsl_update_x64.msi
  # not if  "/package  $env:temp/wsl_update_x64.msi" use '/' then error, package not exist
  Start-Process msiexec.exe -Wait -ArgumentList "/package  $env:temp\wsl_update_x64.msi"
} else {
  write-host "docker already installed"
}
