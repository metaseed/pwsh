[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force

Install-FromGithub 'extrawurst/gitui' '-win\.tar\.gz$' -versionType 'preview' @Remaining