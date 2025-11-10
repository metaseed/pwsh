# NOTE: need to manually select vscode in visual studio 'Environment/Keyboard: keyboard mapping scheme'
[CmdletBinding()]
param (
	[Parameter()]
	[switch]
	$Force
)
Assert-Admin

$vsPath = Get-VSInstallationPath
# C:\Program Files\Microsoft Visual Studio\2022\Professional
# . "$vsPath\Common7\Tools\Launch-VsDevShell.ps1"

$vsCurrentConfig = gci $env:APPDATA\Microsoft\VisualStudio -Recurse User.vsk
# C:\Users\jsong12\AppData\Roaming\Microsoft\VisualStudio\17.0_475919c0\User.vsk
if(!$vsCurrentConfig) {
    Write-Host "No current config found." -ForegroundColor Red
    return
}

Write-Host "current config path: $($vsCurrentConfig.PSPath)"
$configPath = $vsCurrentConfig.DirectoryName

$vskPath = "$vsPath\Common7\IDE\"

# Copy-Item "$PSScriptRoot\VSCode.vsk" -Destination $vsPath -Force:$Force
# Copy-Item "$PSScriptRoot\Current.vsk" -Destination "$configPath" -Force:$Force
Copy-Item "$PSScriptRoot\User.vsk" -Destination "$configPath" -Force:$Force

# Guessing:
# Current.vsk: all the keys of visual Studio config merged together. (include the selected 'vscode.vsk' and others not defined in that file, not include the User.vsk)
# User.vsk: all the user setted keys in the dialog, this small file canbe sync to clould for this user.

# # Invoke-Expression "mklink $vskPath $vskSourcePath"
# New-Item $vskPath -ItemType SymbolicLink -Value $vskSourcePath
Set-StartTask "AutoBackup VS shortcuts" 'C:\Windows\system32\robocopy.exe' "`"$configPath`" `"$PSScriptRoot`" Current.vsk User.vsk /MOT:2"