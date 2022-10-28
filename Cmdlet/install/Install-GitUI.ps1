[CmdletBinding()]
param (
  [Parameter(mandatory = $false,  DontShow, ValueFromRemainingArguments = $true)]$Remaining
)

# ipmo Metaseed.Management -Force

Install-FromGithub 'extrawurst/gitui' '-win\.tar\.gz$' -versionType 'preview' @Remaining