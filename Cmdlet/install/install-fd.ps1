
[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force
Install-FromGithub https://github.com/sharkdp/fd 'aarch64-pc-windows-msvc\.zip$' -versionType 'preview' @Remaining
