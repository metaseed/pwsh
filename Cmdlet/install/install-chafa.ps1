
[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)
ipmo Metaseed.Management -Force # for modify Install-FromGithub related code

# Install-FromGithub 'https://github.com/hpjansson/chafa' '\.tar\.xz$' -versionType 'preview'  @Remaining
https://hpjansson.org/chafa/download/