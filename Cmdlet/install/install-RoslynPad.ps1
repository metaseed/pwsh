[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force
# https://github.com/roslynpad/roslynpad/
Install-FromGithub 'roslynpad/roslynpad' 'RoslynPad\.zip$' @Remaining