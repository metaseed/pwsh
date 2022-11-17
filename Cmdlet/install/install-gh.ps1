[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

ipmo Metaseed.Management -Force

Install-FromGithub 'https://github.com/cli/cli' '_windows_amd64\.zip$' -versionType 'preview' -newName gh -pickExes @Remaining


