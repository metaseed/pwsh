
[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining
)

ipmo Metaseed.Management -Force
Install-FromGithub https://github.com/sxyazi/yazi 'x86_64-pc-windows-msvc\.zip$' -versionType 'stable' @Remaining

# Add-PathEnv 'C:\App\poppler-windows\Library\bin'
New-Item -ItemType HardLink -Path $env:MS_App\_shim\ya.exe -Value c:\app\yazi\ya.exe
New-Item -ItemType HardLink -Path $env:MS_App\_shim\yazi.exe -Value c:\app\yazi\yazi.exe