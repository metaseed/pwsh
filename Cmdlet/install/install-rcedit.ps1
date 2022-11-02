[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force
# ipmo metaseed.management -fo;
$info = Install-FromGithub 'https://github.com/electron/rcedit' '-x64.exe$' -versionType 'preview' @Remaining
