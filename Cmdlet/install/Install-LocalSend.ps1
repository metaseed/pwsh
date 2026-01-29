[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force

Install-FromGithub https://github.com/localsend/localsend  -filter '^LocalSend-.+-windows-x86-64\.zip$' -versionType 'preview' -Verbose @Remaining