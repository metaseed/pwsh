# NOTE: need to select vscode in visual studio 'Environment/Keybord: keyboard mapping scheme'
[CmdletBinding()]
param (
	[Parameter()]
	[switch]
	$Force
)
Assert-Admin
$vsPath = Get-VSInstallationPath
# . "$vsPath\Common7\Tools\Launch-VsDevShell.ps1"
# C:\Users\jsong12\AppData\Roaming\Microsoft\VisualStudio\17.0_475919c0
$configPath = "$((gci $env:APPDATA\Microsoft\VisualStudio -Recurse Current.vsk).Directory)"

$vskPath = "$vsPath\Common7\IDE\"

Copy-Item "$PSScriptRoot\VSCode.vsk" -Destination $vsPath -Force:$Force
Copy-Item "$PSScriptRoot\Current.vsk" -Destination "$configPath" -Force:$Force
Copy-Item "$PSScriptRoot\User.vsk" -Destination "$configPath" -Force:$Force

# Guessing:
# Current.vsk: all the keys of visual Studio config merged together. (include the selected 'vscode.vsk' and others not defined in that file, not include the User.vsk)
# User.vsk: all the user setted keys in the dialog, this small file canbe sync to clould for this user.

# # Invoke-Expression "mklink $vskPath $vskSourcePath"
# New-Item $vskPath -ItemType SymbolicLink -Value $vskSourcePath
Set-StartTask "AutoBackup VS shortcuts" 'C:\Windows\system32\robocopy.exe' "`"$configPath`" `"$PSScriptRoot`" Current.vsk User.vsk /MOT:2"