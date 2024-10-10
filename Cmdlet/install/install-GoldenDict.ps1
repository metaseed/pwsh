# https://github.com/junegunn/fzf
gps -name goldendict -ErrorAction SilentlyContinue |spps -Force
ipmo metaseed.management -fo;
$info = Install-FromGithub 'https://github.com/goldendict/goldendict' '.64bit.7z$' -versionType 'preview' -force # -toFolder
