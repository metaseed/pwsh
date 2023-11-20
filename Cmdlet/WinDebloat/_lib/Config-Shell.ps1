[CmdletBinding()]
param (
  [Parameter()]
  [bool]
  $vm
)

if($vm) {

} else {

}

# Set-HKItemProperty 'HKCU:\Control Panel\International' -name 'sShortDate' -value 'ddd, M/d/yyyy' # ddd is week, i.e. Mon, Tue, Thu. Turned off for [DateTime].Now.ToString() would be changed.

# Write-Host "need to turn off 'use small taskbar icon' in taskbar settings" # TaskbarSettings/Use Small Taskbar Icons
Set-HKItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarSmallicons' -value 0 # 0: large icons; 1: small icons

Set-HKItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarGlomLevel' -value 0 # 0: Always Combine, Hide Labels; 1: Combine when full; 2: Never Combine
# disable win11 widgets
Set-HKItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarDa' -value 0 # 1
# remove chat button from taskbar
Set-HKItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarMn' -value 0 # 1
Set-HKItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ExExSearchame 'TaTaSearchboxTaskbarModealue 0 # 1

write-action 'show My Pc on desktop'
Set-HKItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -Value 'My PC'
write-action 'show Document on desktop'
Set-HKItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' -Value 'Document'
write-action 'show Network Location on desktip'
Set-HKItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}' -Value 'Network Location'
write-action 'show Recycle Bin on desktop'
Set-HKItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{645FF040-5081-101B-9F08-00AA002F954E}' -Value 'Recycle Bin'


Write-Action 'when open explorer, show this pc versus quick access'
$sipParams = @{
  Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
  Name  = 'LaunchTo'
  # 1: this pc; 2: quick access; 3: downloads
  Value = 1 # Set the LaunchTo value for "This PC", default is 2 (Quick Access)
}
Set-HKItemProperty @sipParams


# dark theme
Set-HKItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize "AppsUseLightTheme" 0
Set-HKItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize "SystemUsesLightTheme" 0


# UAC: user account control
# show current config
$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$filter = "ConsentPromptBehaviorAdmin|ConsentPromptBehaviorUser|EnableInstallerDetection|EnableLUA|EnableVirtualization|PromptOnSecureDesktop|ValidateAdminCodeSignatures|FilterAdministratorToken"
(Get-ItemProperty $path).psobject.properties | where { $_.name -match $filter } | select name, value
# disable
# suppress UAC consent prompt dialog
Set-HKItemProperty $path -Name 'ConsentPromptBehaviorAdmin' -Value 0 -PropertyType DWORD -Force | Out-Null #2
Set-HKItemProperty $path -Name 'ConsentPromptBehaviorUser' -Value 3 -PropertyType DWORD -Force | Out-Null
Set-HKItemProperty $path -Name 'EnableInstallerDetection' -Value 1 -PropertyType DWORD -Force | Out-Null
# 1: to enable
Set-HKItemProperty $path -Name 'EnableLUA' -Value 0 -PropertyType DWORD -Force | Out-Null
Set-HKItemProperty $path -Name 'EnableVirtualization' -Value 1 -PropertyType DWORD -Force | Out-Null
Set-HKItemProperty $path -Name 'PromptOnSecureDesktop' -Value 0 -PropertyType DWORD -Force | Out-Null #1
Set-HKItemProperty $path -Name 'ValidateAdminCodeSignatures' -Value 0 -PropertyType DWORD -Force | Out-Null
Write-Host "modified to:"
(Get-ItemProperty $path).psobject.properties | where { $_.name -match $filter } | select name, value

# Hide file extensions for known file types"
Set-HKItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" HideFileExt 0 # 1 to hide
# show hidden files
Set-HKItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" Hidden 1
# spps -n explorer # restart explorer to take effect

# not work to config Lunar cander, have to do it manully
Set-HKItemProperty -Path $path -Name 'FilterAdministratorToken' -Value 0 -PropertyType DWORD -Force | Out-Null

# # Software\Policies\Microsoft\Windows\Settings\AllowConfigureTaskbarCalendar with REG_DWORD (0 Disabled, 1 Enabled, 2 Simplified Chinese (Lunar), 3 Traditional Chinese (Lunar)).
# $win = "HKLM:\Software\Policies\Microsoft\Windows"
# gi "$win\Settings"
# Set-HKItemProperty -Path "$win\Settings" -Name 'AllowConfigureTaskbarCalendar' -Value 2 -PropertyType DWORD -Force | Out-Null


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