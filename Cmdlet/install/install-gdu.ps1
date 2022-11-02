[CmdletBinding()]
param(
  [parameter(Position=0,ValueFromRemainingArguments)]
  [string[]]
  $Remaining
)
# https://github.com/dundee/gdu
# Pretty fast disk usage analyzer written in Go.
Install-FromGithub 'dundee/gdu' 'windows_amd64\.exe\.zip$' -versionType 'preview' -newName gdu @Remaining