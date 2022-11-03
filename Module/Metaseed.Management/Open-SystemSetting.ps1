# https://nasbench.medium.com/a-deep-dive-into-rundll32-exe-642344b41e90
# https://www.tenforums.com/tutorials/77458-rundll32-commands-list-windows-10-a.html
# https://gist.github.com/gabe31415/fe2a7bd7213739b2bc407ecf0e100f9a
function Open-SystemSetting {
  [CmdletBinding()]
  [alias('opss')]
  param (
    [Parameter()]
    [ValidateSet('EnvVar', 'Profiles','DateTime','DeviceManager',
    'OptionalFeatures','NetworkConnections','PowerOptions',
    'DesktopIcons','ScreenSaver','DefaultApp',
    'SystemProperties', 'Region', 'ProgramsAndFeatures', 'Firewall', 'InputLanguage', 'Taskbar',
    'UserAccounts','StoredUserNamePassword','DisplaySettings','ExplorerOptions',
    'FontsFolder', 'GameControllers','IndexingOptions', 'MouseOptions', 'MapNetworkDriver',
    'Background', 'SecurityAndMaintance','Sound','StartSettings'
    )]
    $setting
  )

  switch ($setting) {
    'EnvVar' { rundll32.exe sysdm.cpl, EditEnvironmentVariables }
    'Profiles' { rundll32.exe sysdm.cpl, EditUserProfiles }
    'DateTime' {Rundll32.exe shell32.dll,Control_RunDLL timedate.cpl}
    'DeviceManager'{Rundll32.exe devmgr.dll DeviceManager_Execute}
    'OptionalFeatures'{optionalFeatures} # Rundll32.exe shell32.dll,Control_RunDLL appwiz.cpl,,2
    'ExplorerOptions' {Rundll32.exe shell32.dll,Options_RunDLL 7} # view tab
    'FontsFolder' {Rundll32.exe shell32.dll,SHHelpShortcuts_RunDLL FontsFolder}
    'DisplaySettings'{Rundll32.exe shell32.dll,Control_RunDLL desk.cpl}
    'MapNetworkDriver' {Rundll32.exe shell32.dll,SHHelpShortcuts_RunDLL Connect}
    'NetworkConnections' {Rundll32.exe shell32.dll,Control_RunDLL ncpa.cpl}
    'PowerOptions' {Rundll32.exe shell32.dll,Control_RunDLL powercfg.cpl}
    'DesktopIcons' {Rundll32.exe shell32.dll,Control_RunDLL desk.cpl,0,0}
    'MouseOptions' {Rundll32.exe shell32.dll,Control_RunDLL main.cpl @1}
    'IndexingOptions' {Rundll32.exe shell32.dll,Control_RunDLL srchadmin.dll}
    'GameControllers' {Rundll32.exe shell32.dll,Control_RunDLL joy.cpl}
    'StartSettings' {Rundll32.exe shell32.dll,Options_RunDLL 3}
    'ScreenSaver'{Rundll32.exe shell32.dll,Control_RunDLL desk.cpl,0,1}
    'DefaultApp'{Rundll32.exe shell32.dll,Control_RunDLL appwiz.cpl,0,3}
    'Background'{Rundll32.exe shell32.dll,Control_RunDLL desk.cpl,0,2}
    'Sound' {Rundll32.exe shell32.dll,Control_RunDLL Mmsys.cpl,0,0}
    'SecurityAndMaintance' {Rundll32.exe shell32.dll,Control_RunDLL wscui.cpl}
    'SystemProperties' {Rundll32.exe shell32.dll,Control_RunDLL Sysdm.cpl,0,3}
    'Region' {Rundll32.exe shell32.dll,Control_RunDLL Intl.cpl,0,0}
    'ProgramsAndFeatures' {Rundll32.exe shell32.dll,Control_RunDLL appwiz.cpl,0,0} # appwiz.cpl
    'Firewall' {Rundll32.exe shell32.dll,Control_RunDLL firewall.cpl}
    'InputLanguage'{Rundll32.exe Shell32.dll,Control_RunDLL input.dll,0,{C07337D3-DB2C-4D0B-9A93-B722A6C106E2}}
    'Taskbar' {Rundll32.exe shell32.dll,Options_RunDLL 1}
    'UserAccounts' {Rundll32.exe shell32.dll,Control_RunDLL nusrmgr.cpl}
    'StoredUserNamePassword'{Rundll32.exe keymgr.dll,KRShowKeyMgr}
    Default {}
  }

}