[CmdletBinding()]
param (
  [Parameter(mandatory = $false,  DontShow, ValueFromRemainingArguments = $true)]$Remaining
)

# ipmo Metaseed.Management -Force
# https://github.com/mgunyho/tere
Install-FromGithub 'mgunyho/tere' '-pc-windows-gnu\.zip$' -versionType 'preview' -toFolder @Remaining