# https://www.windowscentral.com/how-use-powercfg-control-power-settings-windows-10
# https://docs.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options#change-or-x
# https://ss64.com/nt/powercfg.html
# Control Panel\All Control Panel Items\Power Options\Edit Plan Settings
# open procexp and view the dialog's command line property
# Rundll32 shell32.dll,Control_RunDLL powercfg.cpl
[CmdletBinding()]
param (
  [Parameter()]
  [bool]
  $vm
)
#  0 will set the timeout=Never
if ($vm) {

}
else {
  # display
  powercfg /change monitor-timeout-dc 10 # 5 dft
  powercfg /change monitor-timeout-ac 20 # 10 dft
  # sleep
  powercfg /change standby-timeout-dc 20
  powercfg /change standby-timeout-ac 60
  # hibernate
  powercfg /change  hibernate-timeout-dc 60
  powercfg /change  hibernate-timeout-ac 0
  # disk
  # disk-timeout-ac default is 20
  # disk-timeout-dc default is 10
}