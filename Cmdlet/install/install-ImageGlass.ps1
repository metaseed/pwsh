[CmdletBinding()]
param(
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

Install-FromGithub 'd2phap/ImageGlass' '_x64.zip$' -versionType 'preview' @Remaining
