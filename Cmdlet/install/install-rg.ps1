
[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

# ipmo Metaseed.Management -Force
Install-FromGithub https://github.com/BurntSushi/ripgrep '-x86_64-pc-windows-msvc\.zip$' -versionType 'preview' -newName rg @Remaining

# not work, when invode: rg.exe --column --line-number --no-heading --color=always --smart-case test
# it will complain about: unknow parameter --column--line-number (space removed)
# shmake -i $env:MS_App\rg\rg.exe -o $env:ms_app\_shim\rg.exe -a "%s"

# single file exe so hardlink works
ni -Type HardLink M:\app\_shim\rg.exe -Value M:\app\rg\rg.exe