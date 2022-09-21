# https://nasbench.medium.com/a-deep-dive-into-rundll32-exe-642344b41e90
# https://www.tenforums.com/tutorials/77458-rundll32-commands-list-windows-10-a.html
function Open-SystemSetting {
  [CmdletBinding()]
  [alias('opss')]
  param (
    [Parameter()]
    [ValidateSet('EnvVar', 'Profiles','DateTime','DeviceManager','OptionalFeatures','NetworkConnections','PowerOptions')]
    $setting
  )

  switch ($setting) {
    'EnvVar' { rundll32.exe sysdm.cpl, EditEnvironmentVariables }
    'Profiles' { rundll32.exe sysdm.cpl, EditUserProfiles }
    'DateTime' {Rundll32.exe shell32.dll,Control_RunDLL timedate.cpl}
    'DeviceManager'{Rundll32.exe devmgr.dll DeviceManager_Execute}
    'OptionalFeatures'{optionalFeatures}
    'NetworkConnections' {Rundll32.exe shell32.dll,Control_RunDLL ncpa.cpl}
    'PowerOptions' {Rundll32.exe shell32.dll,Control_RunDLL powercfg.cpl}
    Default {}
  }

}