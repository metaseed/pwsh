
[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force
Install-FromGithub https://github.com/ImageMagick/ImageMagick 'portable-Q16-HDRI-x64\.7z$' -versionType 'preview' @Remaining
# single file exe so hardlink works
# rm M:\app\_shim\zoxide.exe
# ni -Type HardLink M:\app\_shim\zoxide.exe -Value M:\app\zoxide\zoxide.exe