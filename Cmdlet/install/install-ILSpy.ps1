[CmdletBinding()]
param(
  [parameter(Position=0,ValueFromRemainingArguments)]
  [string[]]
  $Remaining
)

Install-FromGithub 'icsharpcode\ILSpy' '_selfcontained_x64_.+\.zip$' -versionType 'preview' @Remaining
register-FTA "C:\App\dnSpy\dnSpy.exe" .dll