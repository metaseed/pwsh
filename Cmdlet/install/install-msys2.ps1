ipmo Metaseed.Management -Force
Install-FromGithub https://github.com/msys2/msys2-installer 'msys2-base-x86_64-.+\.tar\.zst$' -newName msys64 -versionType 'preview' @args
## install the gcc tool chain
# -l — login shell (loads the MSYS2 environment/PATH)
# -c — run command
C:\app\msys64\usr\bin\bash.exe -lc "pacman -S --noconfirm base-devel mingw-w64-ucrt-x86_64-toolchain" #the gcc tool chain
Add-PathEnv 'C:\app\msys64\ucrt64\bin'
# Add-PathEnv 'C:\app\msys64\usr\bin' # should not in my windows path, it's cygwin-like emulation, tools only for msys bash, pacman

# -S (Sync): Tells pacman to look at the remote repositories.
# -y (Refresh): Downloads a fresh copy of the master package list.
# -u (Sysupgrade): Upgrades all installed packages that have a newer version available.
# pacman -Syu