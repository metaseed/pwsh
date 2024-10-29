[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force

Install-FromGithub https://github.com/jgraph/drawio-desktop 'windows-no-installer\.exe$' -versionType 'preview' -newName drawio -pickExes @Remaining
