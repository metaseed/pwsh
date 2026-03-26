# ipmo Metaseed.Management -Force
Install-FromGithub https://github.com/starship/starship '-x86_64-pc-windows-msvc\.zip$' -versionType 'preview' @args
# Add-PathEnv c:\app\ImageMagick
$initFile = "$env:MS_PWSH\Profile\load\_prompt\starship\.config\starship-init.ps1"
@"
## generated from:
## & 'C:\App\starship.exe' init powershell --print-full-init |code -
##
"@ > $initFile
& 'C:\App\starship.exe' init powershell --print-full-init >> $initFile