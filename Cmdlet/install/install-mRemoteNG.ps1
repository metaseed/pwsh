[CmdletBinding()]
param(
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)
Install-FromGithub 'https://github.com/mRemoteNG/mRemoteNG' '\.rar$' -versionType 'preview' -restoreList @('confCons.xml') @Remaining