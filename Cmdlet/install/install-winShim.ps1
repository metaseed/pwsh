[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

ipmo metaseed.management -fo;
$info = Install-FromGithub 'https://github.com/aloneguid/win-shim' 'shmake.zip$' -application shmake -versionType 'preview' @Remaining

# https://github.com/zoritle/rshim