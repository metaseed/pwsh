[CmdletBinding()]
param(
  [parameter(Position=0,ValueFromRemainingArguments)]
  [string[]]
  $Remaining
)

Install-FromGithub 'BluePointLilac' 'ContextMenuManager' 'ContextMenuManager\.NET\.4\.0\.exe$' -versionType 'preview' @Remaining