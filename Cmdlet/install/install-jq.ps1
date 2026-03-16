
[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

ipmo Metaseed.Management -Force
Install-FromGithub https://github.com/jqlang/jq '-win64\.exe$' -versionType 'preview' -newName jq @Remaining
