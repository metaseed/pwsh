[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force

Install-FromGithub 'icsharpcode\ILSpy' '_selfcontained_x64_.+\.zip$' -versionType 'preview' @Remaining
register-FTA "C:\App\dnSpy\dnSpy.exe" .dll