[CmdletBinding()]
param (
  [Parameter(mandatory = $false,  DontShow, ValueFromRemainingArguments = $true)]$Remaining
)

# ipmo Metaseed.Management -Force

Install-FromGithub 'QL-Win/QuickLook'  -filter '^QuickLook-.+\.zip$' -Verbose @Remaining
