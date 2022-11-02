# 1. on vm: `stop-computer`, then
# 1. on host: enable nested virtualization: Set-VMProcessor -VMName 'win11' -ExposeVirtualizationExtensions $true
if(!(gcm docker -ErrorAction Ignore)) {
  write-host 'download docker...'
  iwr https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe -OutFile $env:temp/docker.exe
  Start-Process -Wait "$env:temp/docker.exe" @('install', '--accept-license', '--backend=wsl-2')

  # https://wsluporustrragm/quostcors/1584710/neckwr-blo-2-in_talateion-im-incomplete
  # https://docs.microsoft.com/en-us/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package
  # Download the Linux kernel update package
  iwr https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile $env:temp/wsl_update_x64.msi

  # constrain of msiexec
  # use '\' not '/': if "/package  $env:temp/wsl_update_x64.msi", then error, package not exist
  Start-Process -Wait  msiexec.exe -ArgumentList "/package  $env:temp\wsl_update_x64.msi"
} else {
  write-host "docker already installed"
}
