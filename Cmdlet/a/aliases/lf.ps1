# delegation script to invoke the lf
# so just invoke the lf.ps1 with 'lf' not 'a lf'
[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

a lf -- @Remaining
# work too:
# & "$PSScriptRoot\..\a\_handlers\lf.ps1" "$env:ms_app\lf.exe" @Remaining