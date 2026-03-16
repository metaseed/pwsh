
[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

ipmo Metaseed.Management -Force
Install-FromGithub https://github.com/sxyazi/yazi 'x86_64-pc-windows-msvc\.zip$' -versionType 'stable' @Remaining

# Add-PathEnv 'C:\App\poppler-windows\Library\bin'