
[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force
Install-FromGithub https://github.com/BurntSushi/ripgrep '-x86_64-pc-windows-msvc\.zip$' -versionType 'preview' -newName rg @Remaining

shmake -i $env:MS_App\rg\rg.exe -o $env:ms_app\_shim\rg.exe -a "%s"