[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force

Install-FromGithub 'QL-Win/QuickLook'  -filter '^QuickLook-.+\.zip$' -Verbose @Remaining
