[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo metaseed.management -fo;
$info = Install-FromGithub 'https://github.com/aloneguid/win-shim' 'shmake.zip$' -versionType 'preview' @Remaining
