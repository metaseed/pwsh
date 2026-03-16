
[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force
Install-FromGithub https://github.com/ajeetdsouza/zoxide 'x86_64-pc-windows-msvc\.zip$' -versionType 'preview' @Remaining -Force
# single file exe so hardlink works
rm M:\app\_shim\zoxide.exe
ni -Type HardLink M:\app\_shim\zoxide.exe -Value M:\app\zoxide\zoxide.exe

## config
# unnecessary: Invoke-Expression (& { (zoxide init powershell | Out-String) })
# &{} is used to create a script block to prevent var-leak
# out-string is needed to convert the string[] (output) into a long string
$file = "$PSScriptRoot\..\..\Profile\load\zoxide.config.ps1"

"###" > $file
"### auto generated from 'zoxide init powershell', see install.zoxide.ps1 for more info" >> $file
"###`r`n" >> $file
zoxide init powershell | Out-String >> $file