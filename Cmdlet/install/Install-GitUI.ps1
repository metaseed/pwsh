[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force

Install-FromGithub 'https://github.com/extrawurst/gitui' '-win\.tar\.gz$' -versionType 'preview' @Remaining