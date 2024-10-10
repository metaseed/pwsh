[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# to reload and debug after modification of lib functions
# ipmo Metaseed.Management -Force

Install-FromGithub https://github.com/torakiki/pdfsam '-windows\.zip$' -versionType 'stable' @Remaining