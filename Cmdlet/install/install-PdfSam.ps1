[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force
Install-FromGithub 'torakiki/pdfsam' '-windows\.zip$' @Remaining