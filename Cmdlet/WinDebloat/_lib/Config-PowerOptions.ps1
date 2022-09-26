# https://www.windowscentral.com/how-use-powercfg-control-power-settings-windows-10
# https://docs.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options#change-or-x
# https://ss64.com/nt/powercfg.html
# Control Panel\All Control Panel Items\Power Options\Edit Plan Settings
# open procexp and view the dialog's command line property
# Rundll32 shell32.dll,Control_RunDLL powercfg.cpl

# https://www.tenforums.com/tutorials/69741-change-default-action-power-button-windows-10-a.html
# https://docs.microsoft.com/en-us/windows-hardware/customize/power-settings/power-button-and-lid-settings
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
  powercfg /change monitor-timeout-dc 10 # 5mins by default
  powercfg /change monitor-timeout-ac 20 # 10mins by default
  # sleep
  powercfg /change standby-timeout-dc 20
  powercfg /change standby-timeout-ac 60
  # hibernate
  powercfg /change  hibernate-timeout-dc 60
  powercfg /change  hibernate-timeout-ac 0
  # disk
  # powercfg /change disk-timeout-ac #default is 20
  # powercfg /change disk-timeout-dc #default is 10

  ## power buttons actions
  ## 0: do nothing; 1: sleep; 2: hibernate; 3: shutdown

  # power button
  powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 2
  powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 2
  # lid close
  powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347  5ca83367-6e45-459f-a27b-476b1d01c936 1
  powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347  5ca83367-6e45-459f-a27b-476b1d01c936 1
  # sleep button
  # powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347  96996bc0-ad50-47ec-923b-6f41874dd9eb 1
  # powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347  96996bc0-ad50-47ec-923b-6f41874dd9eb 1
}