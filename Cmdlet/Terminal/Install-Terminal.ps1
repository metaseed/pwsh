[CmdletBinding()]
param (
  [Parameter(DontShow, ValueFromRemainingArguments)]$Remaining = @()
)

# to reload and debug after modification of lib functions
# ipmo Metaseed.Management -Force
#ipmo Metaseed.Utils -Force
# spps
$positional, $named = Split-RemainParameters $Remaining

$installScript = @"
    Install-FromGithub https://github.com/microsoft/terminal '_x64.zip$' -versionType preview  @positional @named
    # Show-MessageBox "windows terminal updated"
    Read-Host "press any key to close"

"@
$wts = get-process -name "WindowsTerminal" -ErrorAction SilentlyContinue

if ($wts) {
  Confirm-Continue "Windows Terminal is running. Do you want to kill it?"
  stop-process -name "WindowsTerminal", "OpenConsole", "ShellExperienceHost" -force
}
# run pwsh outside of wt
# conhost.exe --headless pwsh.exe -NoProfile -ExecutionPolicy Bypass -Command "$installScript"
conhost.exe pwsh.exe -NoExit -ExecutionPolicy Bypass -Command "$installScript"
Add-PathEnv 'C:\App\Terminal'

# Set Windows Terminal as the default console host
# $wtPath = 'C:\app\terminal\wt.exe'

# # Register wt.exe in App Paths so Windows can find it by name
# $appPathKey = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\wt.exe'
# if (-not (Test-Path $appPathKey)) { New-Item $appPathKey -Force | Out-Null }
# Set-ItemProperty $appPathKey -Name '(Default)' -Value $wtPath
# Set-ItemProperty $appPathKey -Name 'Path'      -Value (Split-Path $wtPath)

# # Register a COM server CLSID for the custom WT installation
# $clsid          = '{E12B3D2B-6849-4C77-8E25-7CD5A7B6F1E4}'
# $clsidKey       = "HKCU:\SOFTWARE\Classes\CLSID\$clsid"
# $localServerKey = "$clsidKey\LocalServer32"

# if (-not (Test-Path $localServerKey)) { New-Item $localServerKey -Force | Out-Null }
# Set-ItemProperty $clsidKey       -Name '(Default)' -Value 'Windows Terminal'
# Set-ItemProperty $localServerKey -Name '(Default)' -Value $wtPath

# # Point the delegation keys at that CLSID
# $delegationKey = 'HKCU:\Console\%%Startup'
# if (-not (Test-Path $delegationKey)) { New-Item $delegationKey -Force | Out-Null }
# Set-ItemProperty $delegationKey -Name 'DelegationConsole'  -Value $clsid
# Set-ItemProperty $delegationKey -Name 'DelegationTerminal' -Value $clsid

# Write-Host "Done. New terminals will open via $wtPath"

