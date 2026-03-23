
[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force
Install-FromGithub https://github.com/sharkdp/fd 'x86_64-pc-windows-msvc\.zip$' -versionType 'preview' @Remaining -Force
Add-PathEnv C:\app\fd