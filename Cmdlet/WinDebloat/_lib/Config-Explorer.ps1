[CmdletBinding()]
param (
  [Parameter()]
  [bool]
  $vm
)


# Set-HKItemProperty 'HKCU:\Control Panel\International' -name 'sShortDate' -value 'ddd, M/d/yyyy' # ddd is week, i.e. Mon, Tue, Thu. Turned off for [DateTime].Now.ToString() would be changed.

# Disable taskbar on secondary monitors, only on main monitor, need to restart explorer
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarEnabled" -Value 0

# Write-Host "need to turn off 'use small taskbar icon' in taskbar settings" # TaskbarSettings/Use Small Taskbar Icons
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarSmallicons' -value 0 -Force # 0: large icons; 1: small icons

Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarGlomLevel' -value 0 -Force # 0: Always Combine, Hide Labels; 1: Combine when full; 2: Never Combine
# disable win11 widgets
Set-HKItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarDa' -value 0 # 1
# remove chat button from taskbar
Set-HKItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarMn' -value 0 # 1
# hide search boxs
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0

write-action 'show My Pc on desktop'
Set-HKItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -Value 'My PC'
write-action 'show Document on desktop'
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' -Value 'Document'
write-action 'show Network Location on desktip'
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}' -Value 'Network Location'
write-action 'show Recycle Bin on desktop'
Set-HKItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{645FF040-5081-101B-9F08-00AA002F954E}' -Value 'Recycle Bin'

# write-action 'hide Recycle Bin on desktop'
# 0: show; 1: hide
# Set-HKItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{645FF040-5081-101B-9F08-00AA002F954E}' -Value 1
# Stop-Process -Name explorer -Force

Write-Action 'when open explorer, show this pc versus home'
$sipParams = @{
  Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
  Name  = 'LaunchTo'
  # 1: this pc; 2: home; 3: downloads
  Value = 1 # Set the LaunchTo value for "This PC", default is 2 (home)
}
Set-HKItemProperty @sipParams


# dark theme
Set-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize "AppsUseLightTheme" 0
Set-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize "SystemUsesLightTheme" 0


# UAC: user account control
# show current config
$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$filter = "ConsentPromptBehaviorAdmin|ConsentPromptBehaviorUser|EnableInstallerDetection|EnableLUA|EnableVirtualization|PromptOnSecureDesktop|ValidateAdminCodeSignatures|FilterAdministratorToken"
(Get-ItemProperty $path).psobject.properties | where { $_.name -match $filter } | select name, value
# disable
# suppress UAC consent prompt dialog
Set-ItemProperty $path -Name 'ConsentPromptBehaviorAdmin' -Value 0 -Type DWORD -Force | Out-Null # default 5 change to 0
Set-ItemProperty $path -Name 'ConsentPromptBehaviorUser' -Value 3 -Type DWORD -Force | Out-Null # 3
Set-ItemProperty $path -Name 'EnableInstallerDetection' -Value 1 -Type DWORD -Force | Out-Null # 1
# 1: to enable
Set-ItemProperty $path -Name 'EnableLUA' -Value 0 -Type DWORD -Force | Out-Null # 1
Set-ItemProperty $path -Name 'EnableVirtualization' -Value 1 -Type DWORD -Force | Out-Null # 1
Set-ItemProperty $path -Name 'PromptOnSecureDesktop' -Value 0 -Type DWORD -Force | Out-Null #1 change to 0
Set-ItemProperty $path -Name 'ValidateAdminCodeSignatures' -Value 0 -Type DWORD -Force | Out-Null # 0
Write-Host "modified to:"
(Get-ItemProperty $path).psobject.properties | where { $_.name -match $filter } | select name, value

# show file extensions for known file types
Set-HKItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" HideFileExt 0 # 1 to hide
# show hidden files
Set-HKItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" Hidden 1
# spps -n explorer # restart explorer to take effect or refresh

# not work to config Lunar cander, have to do it manully
Set-HKItemProperty -Path $path -Name 'FilterAdministratorToken' -Value 0 -Type DWORD -Force | Out-Null

# # Software\Policies\Microsoft\Windows\Settings\AllowConfigureTaskbarCalendar with REG_DWORD (0 Disabled, 1 Enabled, 2 Simplified Chinese (Lunar), 3 Traditional Chinese (Lunar)).
# $win = "HKLM:\Software\Policies\Microsoft\Windows"
# gi "$win\Settings"
# Set-HKItemProperty -Path "$win\Settings" -Name 'AllowConfigureTaskbarCalendar' -Value 2 -Type DWORD -Force | Out-Null


# An application should use this function if it performs an action that may affect the Shell.
$code = @'
  [System.Runtime.InteropServices.DllImport("Shell32.dll")]
  private static extern int SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2);

  public static void Refresh()  {
      SHChangeNotify(0x8000000, 0x1000, IntPtr.Zero, IntPtr.Zero);
  }
'@

Add-Type -MemberDefinition $code -Namespace WinAPI -Name Explorer
[WinAPI.Explorer]::Refresh()

Set-TimeZoneTo paris


# Set Touchpad Four-finger gestures, need to restart explorer
# up: volumn up; down: volumn down; left: previous track; right: next track; tap: nofitication center
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad"
$regName = "FourFingerSlideEnabled"
# 0Nothing
# 1Switch apps and show desktop
# 2Switch desktops and show desktop
# 3Change audio and volume
$regValue = 3

# Create the key if it doesn't exist
If (-Not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Set the value
Set-ItemProperty -Path $regPath -Name $regName -Value $regValue

##  show the Recycle Bin in the explorer navigation pane
$regPath = "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}"
Remove-Item -Path $regPath -Recurse -Force
New-Item -Path $regPath -Force | Out-Null
New-ItemProperty -Path $regPath -Name "System.IsPinnedToNameSpaceTree" -PropertyType DWord -Value 1 -Force | Out-Null
# Show Downloads folder in the explorer navigation pane
$downloadsRegPath = "HKCU:\Software\Classes\CLSID\{374DE290-123F-4565-9164-39C4925E467B}"
Remove-Item -Path $downloadsRegPath -Recurse -Force -ErrorAction SilentlyContinue
New-Item -Path $downloadsRegPath -Force | Out-Null
New-ItemProperty -Path $downloadsRegPath -Name "System.IsPinnedToNameSpaceTree" -PropertyType DWord -Value 1 -Force | Out-Null
# Stop-Process -Name explorer -Force

# Minimal version - disables animations and transparency
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
## restart explorer
# need to restart explor to take effect:
# * Touchpad Four-finger gestures after registery modification
# * Disable taskbar on secondary monitors
# *  show the Recycle Bin in the explorer navigation pane

## disable smart screen from explorer process for apps, i.e. if I run metatool.exe and a notification shows up: Open File Security Warning: the publisher could not ve verified. Are you sure you want to run this software?(unknown publisher)
## Settings → Privacy & Security → Windows Security → App & browser control,  Reputation-based protection settings,  Check apps and files
# Disable SmartScreen (set to Off)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value "Off"
# # Alternative: Set to Warn (shows warning but allows bypass)
# Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value "Warn"
# # To re-enable (Recommended default)
# Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value "RequireAdmin"
gps explorer|spps

## not easy
# turn on lunar calendar
