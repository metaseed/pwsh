[CmdletBinding()]
param(
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

Install-FromGithub 'https://github.com/d2phap/ImageGlass' '_x64.zip$' -versionType 'preview' @Remaining
