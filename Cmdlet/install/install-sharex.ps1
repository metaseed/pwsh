# Screen capture, file sharing and productivity tool
[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

ipmo Metaseed.Management -Force

Install-FromGithub https://github.com/ShareX/ShareX '\-portable\.zip$' -versionType 'preview' @Remaining