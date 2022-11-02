[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force

Install-FromGithub 'NickeManarin/ScreenToGif' '(?<!\.Light).Portable.x64.zip$' -versionType 'stable' @Remaining