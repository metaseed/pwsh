# Set-ItemProperty -Path 'HKCU:\Control Panel\International' -name 'sShortDate' -value 'ddd, M/d/yyyy' # ddd is week, i.e. Mon, Tue, Thu. Turned off for [DateTime].Now.ToString() would be changed.
# Write-Host "need to turn off 'use small taskbar icon' in taskbar settings" # TaskbarSettings/Use Small Taskbar Icons
Set-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarSmallicons' -value 0 # 0: large icons; 1: small icons

Set-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarGlomLevel' -value 0 # 0: Always Combine, Hide Labels; 1: Combine when full; 2: Never Combine

write-action 'show My Pc on desktop'
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -Value 'My PC'
write-action 'show Document on desktop'
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' -Value 'Document'
write-action 'show Network Location on desktip'
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}' -Value 'Network Location'
write-action 'show Recycle Bin on desktop'
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{645FF040-5081-101B-9F08-00AA002F954E}' -Value 'Recycle Bin'

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
Set-ItemProperty @sipParams

write-action 'Disable Connected User Experiences and Telemetry'
# https://www.windowscentral.com/how-opt-out-customer-experience-improvement-program-windows-10
# http://www.kjrnet.com/Info/Windows%207%20Hidden%20Settings%202.html
function Disable-Task {
  [CmdletBinding()]
  param (
    [Parameter(ValueFromPipeline)] # to support pipeline
    $taskName
  )
  process { # to process item one by one from pipeline
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
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows' -Name 'CEIPEnable' -Value 0 -PropertyType Dword

# In Windows 11, before disabling Windows Defender through the registry or a GPO, you must manually disable the Tamper Protection feature. Tamper Protection prevents changes to Windows Defender security features via PowerShell, registry settings, and/or Group Policy options. 
# need to disable first: Tamper Protection
# https://theitbros.com/managing-windows-defender-using-powershell/
# disable realtime monitor
# Set-MpPreference -DisableRealtimeMonitoring $true
# disable Windows Defender
# New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force
# to reset need to `win` search "Windows Security", then 'app settings' then reset


# Network Discovery:
# https://www.majorgeeks.com/content/page/how_to_turn_on_or_off_network_discovery.html
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
# File and Printer Sharing:
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
# Hide file extensions for known file types"
Set-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced HideFileExt "0" # 1 to hide
# spps -n explorer # restart explorer to take effect

# UAC: user account control
# show current config
$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$filter="ConsentPromptBehaviorAdmin|ConsentPromptBehaviorUser|EnableInstallerDetection|EnableLUA|EnableVirtualization|PromptOnSecureDesktop|ValidateAdminCodeSignatures|FilterAdministratorToken"
(Get-ItemProperty $path).psobject.properties | where {$_.name -match $filter} | select name,value
# disable 
$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
New-ItemProperty -Path $path -Name 'ConsentPromptBehaviorAdmin' -Value 0 -PropertyType DWORD -Force | Out-Null #2
New-ItemProperty -Path $path -Name 'ConsentPromptBehaviorUser' -Value 3 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $path -Name 'EnableInstallerDetection' -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $path -Name 'EnableLUA' -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $path -Name 'EnableVirtualization' -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $path -Name 'PromptOnSecureDesktop' -Value 0 -PropertyType DWORD -Force | Out-Null #1
New-ItemProperty -Path $path -Name 'ValidateAdminCodeSignatures' -Value 0 -PropertyType DWORD -Force | Out-Null
# New-ItemProperty -Path $path -Name 'FilterAdministratorToken' -Value 0 -PropertyType DWORD -Force | Out-Null