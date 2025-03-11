[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining = @()
)

# to reload and debug after modification of lib functions
# ipmo Metaseed.Management -Force
#ipmo Metaseed.Utils -Force
$positional, $named= Split-RemainParameters $Remaining
Install-FromGithub https://github.com/microsoft/terminal '_x64.zip$' -versionType preview  @positional @named