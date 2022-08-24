[CmdletBinding()]
param(
  [parameter(Position=0,ValueFromRemainingArguments)]
  [string[]]
  $Remaining
)

Install-FromGithub 'extrawurst' 'gitui' '-win\.tar\.gz$' -versionType 'preview' -tofolder @Remaining