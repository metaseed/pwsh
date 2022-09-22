# https://nasbench.medium.com/a-deep-dive-into-rundll32-exe-642344b41e90
# https://www.tenforums.com/tutorials/77458-rundll32-commands-list-windows-10-a.html
function Open-SystemSetting {
  [CmdletBinding()]
  [alias('opss')]
  param (
    [Parameter()]
    [ValidateSet('EnvVar', 'Profiles','DateTime','DeviceManager',
    'OptionalFeatures','NetworkConnections','PowerOptions',
    'DesktopIcons','ScreenSaver','DefaultApp',
    'SystemProperties', 'Region')]
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
    'DesktopIcons' {Rundll32.exe shell32.dll,Control_RunDLL desk.cpl,0,0}
    'ScreenSaver'{Rundll32.exe shell32.dll,Control_RunDLL desk.cpl,0,1}
    'DefaultApp'{Rundll32.exe shell32.dll,Control_RunDLL appwiz.cpl,0,3}
    'SystemProperties' {Rundll32.exe shell32.dll,Control_RunDLL Sysdm.cpl,0,3}
    'Region'{Rundll32.exe shell32.dll,Control_RunDLL Intl.cpl,0,0}
    Default {}
  }

}