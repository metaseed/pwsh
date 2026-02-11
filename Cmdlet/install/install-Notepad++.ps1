[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force

Install-FromGithub 'https://github.com/notepad-plus-plus/notepad-plus-plus' '\.portable\.x64\.zip$' -versionType 'preview' @Remaining