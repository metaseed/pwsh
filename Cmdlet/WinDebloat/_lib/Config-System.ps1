
[CmdletBinding()]
param (
  [Parameter()]
  [bool]
  $vm
)

if ($vm) {
  # disable wifi
  Set-HKItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\RmSvc" "Start" 4 -descriptoin "Disabling RmSvc (Radio Management Service) service"
  Get-Service RmSvc | Set-Service -StartupType disabled # access denied

    # "Disabling Action Center global toasts..."
    Set-HKItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings' -name 'NOC_GLOBAL_SETTING_TOASTS_ENABLED' -value 0

  # auto login
  # not work for enhanced mode of Hyper-V
  # hyper-v enhanced mode can not auto login, have to use basic mode
  Set-HKItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -name 'AutoAdminLogon' -value 1  -PropertyType String
  # Set-HKItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -name 'ForceAutoLogon' -value 1  -PropertyType Dword
  # Set-HKItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -name 'ForceUnlockLogon' -value 1  -PropertyType Dword
  Set-HKItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -name 'DefaultUserName' -value '0' -PropertyType string
  Set-HKItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -name 'DefaultPassword' -value '0' -PropertyType string

  
  # not work, have to do it with group policy:c omputer Configuration > Administrative Templates > Windows Components > Microsoft Defender Antivirus;
  # In Windows 11, before disabling Windows Defender through the registry or a GPO, you must manually disable the Tamper Protection feature. Tamper Protection prevents changes to Windows Defender security features via PowerShell, registry settings, and/or Group Policy options. 
  # need to disable first: Tamper Protection
  # https://theitbros.com/managing-windows-defender-using-powershell/
  # disable realtime monitor
  # Set-MpPreference -DisableRealtimeMonitoring $true
  # disable Windows Defender
  # Set-HKItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force
  # to reset need to `win` search "Windows Security", then 'app settings' then reset

  # to install local appx package, the firewall need to be turned on
  # turn off firewall
  # Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled False
  # disable windows defineder firewall
  # note: can not disable the service with Set-Service, show user can not disalbe it
  # Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\mpssvc' -Name 'start' -Value 4 # 2 is default
  
}
else {
  
}

# Network Discovery:
# https://www.majorgeeks.com/content/page/how_to_turn_on_or_off_network_discovery.html
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes

# File and Printer Sharing:
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes


# Windows Customer Experience Improvement program
# 0: disable; 1: enable
Set-HKItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows' -Name 'CEIPEnable' -Value 0 -PropertyType Dword

## 
## Disable Autoruns
##
$autoRunBackup = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellServiceObjects\AutorunsDisabled"
if (!(Test-Path $autoRunBackup)) {
  New-Item $autoRunBackup -Force
}

$WOWAutoRunBackup = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellServiceObjects\AutorunsDisabled"
if (!(Test-Path $WOWAutoRunBackup)) {
  New-Item $WOWAutoRunBackup -Force
}

# disable Windows Sync Center
Move-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellServiceObjects\{F20487CC-FC04-4B1E-863F-D9801796130B}" "$autoRunBackup\{F20487CC-FC04-4B1E-863F-D9801796130B}" -Force
Move-Item "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellServiceObjects\{F56F6FDD-AA9D-4618-A949-C1B91AF43B1A}" "$WOWAutoRunBackup\{F20487CC-FC04-4B1E-863F-D9801796130B}" -Force

# https://www.itechtics.com/add-language-using-powershell/
if(gcm Install-Language -ErrorAction SilentlyContinue) {
  Install-Language zh-CN
}