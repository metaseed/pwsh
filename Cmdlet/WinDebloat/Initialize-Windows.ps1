# https://github.com/gordonbay/Windows-On-Reins/blob/master/wor.ps1

# String: Specifies a null-terminated string. Equivalent to REG_SZ.
# ExpandString: Specifies a null-terminated string that contains unexpanded references to environment variables that are expanded when the value is retrieved. Equivalent to REG_EXPAND_SZ.
# Binary: Specifies binary data in any form. Equivalent to REG_BINARY.
# DWord: Specifies a 32-bit binary number. Equivalent to REG_DWORD.
# MultiString: Specifies an array of null-terminated strings terminated by two null characters. Equivalent to REG_MULTI_SZ.
# Qword: Specifies a 64-bit binary number. Equivalent to REG_QWORD.
# Unknown: Indicates an unsupported registry data type, such as REG_RESOURCE_LIST.
function Write-ItemProperty($path, $name, $value, $type, $descriptoin) {
  if (Test-Path $path) {
    if ($type) {
      Set-ItemPropertyPath $path -Name $name -Value $value -Type $type
    }
    else {
      Set-ItemPropertyPath $path -Name $name -Value $value
    }
  }
  else {
    if ($type) {
      New-ItemPropertyPath $path -Name $name -Value $value -PropertyType $type
    }
    else {
      New-ItemPropertyPath $path -Name $name -Value $value

    }

  }
  if ($descriptoin) {
    Write-Host $descriptoin
  }
}

# Write-ItemPropertyPath 'HKCU:\Control Panel\International' -name 'sShortDate' -value 'ddd, M/d/yyyy' # ddd is week, i.e. Mon, Tue, Thu. Turned off for [DateTime].Now.ToString() would be changed.
# Write-Host "need to turn off 'use small taskbar icon' in taskbar settings" # TaskbarSettings/Use Small Taskbar Icons
Write-ItemPropertypath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarSmallicons' -value 0 # 0: large icons; 1: small icons

Write-ItemPropertypath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarGlomLevel' -value 0 # 0: Always Combine, Hide Labels; 1: Combine when full; 2: Never Combine
# disable win11 widgets
Write-ItemPropertypath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarDa' -value 0 # 1
# remove chat button from taskbar
Write-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarMn' -value 0 # 1
Write-ItemPropertypath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ExExSearchame 'TaTaSearchboxTaskbarModealue 0 # 1

if ($vm) {
  # disable wifi
  Write-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\RmSvc" "Start" 4 -descriptoin "Disabling RmSvc (Radio Management Service) service"
  Get-Service RmSvc | Set-Service -StartupType disabled # access denied
  # not work for enhanced mode
  # hyper-v enhanced mode can not auto login, have to use basic mode
  Write-ItemPropertypath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -name 'AutoAdminLogon' -value 1  -PropertyType String
  # Write-ItemPropertypath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -name 'ForceAutoLogon' -value 1  -PropertyType Dword
  # Write-ItemPropertypath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -name 'ForceUnlockLogon' -value 1  -PropertyType Dword
  Write-ItemPropertypath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -name 'DefaultUserName' -value '0' -PropertyType string
  Write-ItemPropertypath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -name 'DefaultPassword' -value '0' -PropertyType string
  # "Disabling Action Center global toasts..."
  Write-ItemPropertypath 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings' -name 'NOC_GLOBAL_SETTING_TOASTS_ENABLED' -value 0

  # not work, have to do it with grop policy: omputer Configuration > Administrative Templates > Windows Components > Microsoft Defender Antivirus;
  # In Windows 11, before disabling Windows Defender through the registry or a GPO, you must manually disable the Tamper Protection feature. Tamper Protection prevents changes to Windows Defender security features via PowerShell, registry settings, and/or Group Policy options. 
  # need to disable first: Tamper Protection
  # https://theitbros.com/managing-windows-defender-using-powershell/
  # disable realtime monitor
  # Set-MpPreference -DisableRealtimeMonitoring $true
  # disable Windows Defender
  # Write-ItemPropertyPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force
  # to reset need to `win` search "Windows Security", then 'app settings' then reset

  # remove your phone
  @('*FeedbackHub*', '*YourPhone*') |
  % { Get-AppxPackage $_ -AllUsers | Remove-AppxPackag }

  # disable Windows Sync Center
 

  $p = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellServiceObjects\AutorunsDisabled"
  if (!(Test-Path $p)) {
    New-Item $p
  }
  Move-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellServiceObjects\{F20487CC-FC04-4B1E-863F-D9801796130B}" "$p\{F20487CC-FC04-4B1E-863F-D9801796130B}"

  $p = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellServiceObjects\AutorunsDisabled"
  if (!(Test-Path $p)) {
    New-Item $p
  }
  Move-Item "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellServiceObjects\{F56F6FDD-AA9D-4618-A949-C1B91AF43B1A}" "$p\{F20487CC-FC04-4B1E-863F-D9801796130B}"


  # remove xbox
  $XboxApps = @(
    "Microsoft.GamingServices"          # Gaming Services
    "Microsoft.XboxApp"                 # Xbox Console Companion (Replaced by new App)
    "Microsoft.XboxGameCallableUI"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.XboxGamingOverlay"       # Xbox Game Bar
    "Microsoft.XboxIdentityProvider"    # Xbox Identity Provider (Xbox Dependency)
    "Microsoft.Xbox.TCUI"               # Xbox Live API communication (Xbox Dependency)
)
  $XboxApps |
  # ? { $_.PackageName -match "Microsoft.Xbox" } |
  % {Remove-AppxPackage  $_.PackageName }

  $XboxServices = @(
    "XblAuthManager"                    # Xbox Live Auth Manager
    "XblGameSave"                       # Xbox Live Game Save
    "XboxGipSvc"                        # Xbox Accessory Management Service
    "XboxNetApiSvc"
  )
  $XboxServices | % { Get-ScheduledTask $_ } | Disable-ScheduledTask

  # to install local appx package, the firewall need to be turned on
  # turn off firewall
  # Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled False
  # disable windows defineder firewall
  # note: can not disable the service with Set-Service, show user can not disalbe it
  # Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\mpssvc' -Name 'start' -Value 4 # 2 is default
  
  $services = @(
    # needed by WT 'TabletInputService', # Touch keyboard and Handwriting Panel Service
    'BthAvctpSvc', #stop Bluetooth Audio Video Control Transport Protocol service service
    'DiagTrack' # Connected User Experiences and Telemetry
    'lfsvc' # Geolocation Service
    # not work access denied'CertPropSvc' # Certificate Propagation for smart card reader
    # 'mpssvc', # Windows Defender Firewall
    # 'wscsvc' # Windows Security center service
  )

  $services | % { Set-Service $_ -Status Stopped -StartupType Disabled }

  # disable windows definder service 
  # this way is also not work, can not modify the value even manully
  # Write-ItemPropertyHKLM:\SYSTEM\CurrentControlSet\Services\wscsvc' -Name 'start' -Value 4 # 2 is default Windows Security center service
  # Write-ItemPropertyHKLM:\SYSTEM\CurrentControlSet\Services\WinDefend' -Name 'start' -Value 4 # 2 is default
  # https://www.alitajran.com/turn-off-windows-defender-in-windows-10-permanently/
  # this way 

  @(
    'Microsoft.WindowsCamera',
    'MicrosoftTeams',
    'Microsoft.WindowsAlarms',
    'Microsoft.WindowsMaps',
    'Microsoft.ZuneMusic',
    'Microsoft.ZuneVideo',
    'Microsoft.Getstarted',
    'Microsoft.People',
    'Microsoft.BingWeather',
    'microsoft.windowscommunicationsapps', # mails and calendar
    'Microsoft.MicrosoftSolitaireCollection',
    'Microsoft.GamingApp',
    'Microsoft.BingNews',
    'Microsoft.OneDriveSync',
    'Microsoft.549981C3F5F10',
    'Microsoft.Todos',
    'Microsoft.MicrosoftOfficeHub',
    'Microsoft.MicrosoftStickyNotes',
    'Microsoft.GetHelp'
  ) | % {
    Get-AppPackage $_ | Remove-AppPackage
  }

  # uninstall one drive
  cmd /c (Get-ItemPropertyValue HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe UninstallString)

}

write-action 'show My Pc on desktop'
Write-ItemPropertyPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -Value 'My PC'
write-action 'show Document on desktop'
Write-ItemPropertyPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' -Value 'Document'
write-action 'show Network Location on desktip'
Write-ItemPropertyPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}' -Value 'Network Location'
write-action 'show Recycle Bin on desktop'
Write-ItemPropertyPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{645FF040-5081-101B-9F08-00AA002F954E}' -Value 'Recycle Bin'

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

Write-Action 'when open explorer, show this pc versus quick access'
$sipParams = @{
  Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
  Name  = 'LaunchTo'
  # 1: this pc; 2: quick access; 3: downloads
  Value = 1 # Set the LaunchTo value for "This PC", default is 2 (Quick Access)
}
Write-ItemPropertysipParams

write-action 'Disable Connected User Experiences and Telemetry'
# https://www.windowscentral.com/how-opt-out-customer-experience-improvement-program-windows-10
# http://www.kjrnet.com/Info/Windows%207%20Hidden%20Settings%202.html
function Disable-Task {
  [CmdletBinding()]
  param (
    [Parameter(ValueFromPipeline)] # to support pipeline
    $taskName
  )
  process {
    # to process item one by one from pipeline
    $task = Get-ScheduledTask "$taskName" -ErrorAction SilentlyContinue
    if ($null -ne $task) {
      if ('Disabled' -eq $task.State) {
        "Already disabled: TaskName: $($task.TaskName), TaskPath: $($task.TaskPath)"
        return
      }
      Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath
      $taskN = Get-ScheduledTask "$taskName" -ErrorAction SilentlyContinue
      " $($task.State) -> $($taskN.State): TaskName: $($task.TaskName), TaskPath: $($task.TaskPath)"
    }
  }
}
$tasks = @('StartupAppTask',
  'Microsoft Compatibility Appraiser', 'ProgramDataUpdater', 'PcaPatchDbTask', # Applicaton Experience
  'Consolidator', 'UsbCeip', # Customer Experience Improvement Program
  'Microsoft-Windows-DiskDiagnosticDataCollector', 'Microsoft-Windows-DiskDiagnosticResolver' # DiskDiagnostic
)
$tasks | Disable-Task
$k = gci 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows' -ErrorAction SilentlyContinue
if ($null -eq $k) {
  ni 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows' -f
}
Write-ItemPropertyPath 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows' -Name 'CEIPEnable' -Value 0 -PropertyType Dword


# Network Discovery:
# https://www.majorgeeks.com/content/page/how_to_turn_on_or_off_network_discovery.html
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
# File and Printer Sharing:
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
# Hide file extensions for known file types"
Write-ItemPropertyKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced HideFileExt "0" # 1 to hide
Write-ItemPropertyKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced Hidden 1 # show hidden files
# spps -n explorer # restart explorer to take effect

# UAC: user account control
# show current config
$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$filter = "ConsentPromptBehaviorAdmin|ConsentPromptBehaviorUser|EnableInstallerDetection|EnableLUA|EnableVirtualization|PromptOnSecureDesktop|ValidateAdminCodeSignatures|FilterAdministratorToken"
(Get-ItemProperty $path).psobject.properties | where { $_.name -match $filter } | select name, value
# disable 
$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Write-ItemPropertyPath $path -Name 'ConsentPromptBehaviorAdmin' -Value 0 -PropertyType DWORD -Force | Out-Null #2
Write-ItemPropertyPath $path -Name 'ConsentPromptBehaviorUser' -Value 3 -PropertyType DWORD -Force | Out-Null
Write-ItemPropertyPath $path -Name 'EnableInstallerDetection' -Value 1 -PropertyType DWORD -Force | Out-Null
Write-ItemPropertyPath $path -Name 'EnableLUA' -Value 1 -PropertyType DWORD -Force | Out-Null
Write-ItemPropertyPath $path -Name 'EnableVirtualization' -Value 1 -PropertyType DWORD -Force | Out-Null
Write-ItemPropertyPath $path -Name 'PromptOnSecureDesktop' -Value 0 -PropertyType DWORD -Force | Out-Null #1
Write-ItemPropertyPath $path -Name 'ValidateAdminCodeSignatures' -Value 0 -PropertyType DWORD -Force | Out-Null
# not work to config Lunar cander, have to do it manully
ty -Path $path -Name 'FilterAdministratorToken' -Value 0 -PropertyType DWORD -Force | Out-Nullllllllllllllllllll
# # Software\Policies\Microsoft\Windows\Settings\AllowConfigureTaskbarCalendar with REG_DWORD (0 Disabled, 1 Enabled, 2 Simplified Chinese (Lunar), 3 Traditional Chinese (Lunar)).
# $win = "HKLM:\Software\Policies\Microsoft\Windows"
# gi "$win\Settings"
# Write-ItemProperty -Path "$win\Settings" -Name 'AllowConfigureTaskbarCalendar' -Value 2 -PropertyType DWORD -Force | Out-Null

# disable Tasks
Get-ScheduledTask *google* | Disable-ScheduledTask
Get-ScheduledTask *MicrosoftEdge* | Disable-ScheduledTask
Get-ScheduledTask *OneDrive* | Disable-ScheduledTask

# dark theme
Write-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize "AppsUseLightTheme" 0
Write-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize "SystemUsesLightTheme" 0