[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force

Install-FromGithub https://github.com/QL-Win/QuickLook  -filter '^QuickLook-.+\.zip$' -versionType 'preview' -Verbose @Remaining
