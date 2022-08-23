[CmdletBinding()]
param(
  [parameter(Position=0,ValueFromRemainingArguments)]
  [string[]]
  $Remaining
)

Install-FromGithub 'd2phap' 'ImageGlass' '_x64.zip$' -versionType 'preview' @Remaining
