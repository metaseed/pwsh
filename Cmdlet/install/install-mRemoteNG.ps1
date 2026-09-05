[CmdletBinding()]
param(
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)
Install-FromGithub 'https://github.com/mRemoteNG/mRemoteNG' 'x64\.rar$' -versionType 'preview' -restoreList @('confCons.xml') @Remaining