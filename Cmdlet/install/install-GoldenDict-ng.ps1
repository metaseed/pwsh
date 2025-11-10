# https://github.com/junegunn/fzf
gps -name goldendict -ErrorAction SilentlyContinue |spps -Force
ipmo metaseed.management -fo;
# note: there are other qu versions support, but this is the latest as of today: 10/07/20025
# https://xiaoyifang.github.io/goldendict-ng/install/
$info = Install-FromGithub 'https://github.com/xiaoyifang/goldendict-ng' 'Qt6.7.2-Windows-installer.7z$' -versionType 'stable' -force # -toFolder
if(!(Test-Path $env:MS_App\goldendict-ng\portable)) {
    New-Item -ItemType Directory -Path $env:MS_App\goldendict-ng\portable
}