[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

ipmo Metaseed.Management -Force

Install-FromGithub https://github.com/STaRDoGG/GeekDrop-Props '^GeekDrop_Props.+\.zip$|Props\.exe$' -versionType 'preview' -newName GDProps @Remaining