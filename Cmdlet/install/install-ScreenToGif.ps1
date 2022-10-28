[CmdletBinding()]
param(
  [parameter(Position=0,ValueFromRemainingArguments)]
  [string[]]
  $Remaining
)

Install-FromGithub 'NickeManarin/ScreenToGif' '(?<!\.Light).Portable.x64.zip$' -versionType 'stable' @Remaining