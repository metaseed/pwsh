[CmdletBinding()]
param(
  [parameter(Position=0,ValueFromRemainingArguments)]
  [string[]]
  $Remaining
)
# https://github.com/dundee/gdu
# Pretty fast disk usage analyzer written in Go.
# Fast looking up/manage big files that consume too much space.
# gdu: Go Disk Usage
Install-FromGithub 'dundee/gdu' 'windows_amd64\.exe\.zip$' -versionType 'preview' -newName gdu @Remaining