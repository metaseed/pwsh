[CmdletBinding()]
param(
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

Install-FromGithub 'BluePointLilac/ContextMenuManager' 'ContextMenuManager\.NET\.4\.0\.exe$' -versionType 'preview' @Remaining