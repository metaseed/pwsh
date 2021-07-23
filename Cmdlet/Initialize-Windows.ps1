# Set-ItemProperty -Path 'HKCU:\Control Panel\International' -name 'sShortDate' -value 'ddd, M/d/yyyy' # ddd is week, i.e. Mon, Tue, Thu. Turned off for [DateTime].Now.ToString() would be changed.
# Write-Host "need to turn off 'use small taskbar icon' in taskbar settings" # TaskbarSettings/Use Small Taskbar Icons
Set-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarSmallicons' -value 0 # 0: large icons; 1: small icons

Set-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -name 'TaskbarGlomLevel' -value 0 # 0: Always Combine, Hide Labels; 1: Combine when full; 2: Never Combine
'show My Pc on desktop'
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -Value 'My PC'
'show Document on desktop'
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' -Value 'Document'
'show Network Location on desktip'
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}' -Value 'Network Location'
'show Recycle Bin on desktop'
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{645FF040-5081-101B-9F08-00AA002F954E}' -Value 'Recycle Bin'
$code = @'
  [System.Runtime.InteropServices.DllImport("Shell32.dll")] 
  private static extern int SHChangeNotify(int eventId, int flags, IntPtr item1, IntPtr item2);

  public static void Refresh()  {
      SHChangeNotify(0x8000000, 0x1000, IntPtr.Zero, IntPtr.Zero);    
  }
'@

Add-Type -MemberDefinition $code -Namespace WinAPI -Name Explorer 
[WinAPI.Explorer]::Refresh()


# disable Connected User Experiences and Telemetry
# https://www.windowscentral.com/how-opt-out-customer-experience-improvement-program-windows-10
# http://www.kjrnet.com/Info/Windows%207%20Hidden%20Settings%202.html
function Disable-Task {
  [CmdletBinding()]
  param (
    [Parameter(ValueFromPipeline)]
    $taskName
  )
  process {
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