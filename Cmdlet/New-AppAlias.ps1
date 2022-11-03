# https://superuser.com/questions/1728816/manage-windows-app-execution-aliases-from-powershell
# not work as expected
# can not create a shim like what windows store app do.
[CmdletBinding()]
param (
  # the name with ext
  [Parameter()]
  [string]
  $alias,
  # application path
  [Parameter()]
  [string]
  $appPath
)
# https://superuser.com/questions/1728816/manage-windows-app-execution-aliases-from-powershell
# https://stackoverflow.com/questions/62474046/how-do-i-find-the-target-of-a-windows-app-execution-alias-in-c-win32-api
# https://superuser.com/questions/1437590/typing-python-on-windows-10-version-1903-command-prompt-opens-microsoft-stor/1652617#answer-1652617
# https://oofhours.com/2020/08/13/command-line-apps-from-the-store-how-does-that-work/
#  $env:LOCALAPPDATA\Microsoft\WindowsApps\
# note can not delete items in folder from explorer, have to use pwsh in admin:
#  Remove-Item $env:LOCALAPPDATA\Microsoft\WindowsApps\python.exe
<#
 <uap3:AppExecutionAlias>
            <desktop:ExecutionAlias Alias="contosoapp.exe" />
          </uap3:AppExecutionAlias>
#>

# fsutil reparsepoint query "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"
# can only run with win+r
$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\$alias"
if ((Test-Path -LiteralPath $path ) -ne $true) {
  New-Item $path -force -ea SilentlyContinue
};
$dir = Split-Path $appPath
New-ItemProperty -LiteralPath $path -Name '(default)' -Value $appPath -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath $path -Name 'Path`' -Value "$dir" -PropertyType String -Force -ea SilentlyContinue;

# note below parse link not work for app that has dll dependency
try {
  New-Item -Type HardLink "$env:LOCALAPPDATA\Microsoft\WindowsApps\$alias" -v $appPath -ErrorAction SilentlyContinue
} catch {
  New-Item -Type SymbolicLink "$env:LOCALAPPDATA\Microsoft\WindowsApps\$alias" -v $appPath -Force
}