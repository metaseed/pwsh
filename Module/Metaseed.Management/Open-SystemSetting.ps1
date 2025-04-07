$commands = @{
  "AboutWindows" = "Rundll32.exe shell32.dll,ShellAbout"
  "AddNetworkLocationWizard" = "Rundll32 %SystemRoot%\system32\shwebsvc.dll,AddNetPlaceRunDll"
  "AddPrinterWizard" = "Rundll32.exe shell32.dll,SHHelpShortcuts_RunDLL AddPrinter"
  "AddStandardTcpIpPrinterPortWizard" = "Rundll32.exe tcpmonui.dll,LocalAddPortUI"
  "Background" = "Rundll32.exe shell32.dll,Control_RunDLL desk.cpl,0,2"
  "Bluetooth" = "Start-Process 'ms-settings:bluetooth'"
  "ControlPanel" = "Rundll32.exe shell32.dll,Control_RunDLL"
  "DateAndTime" = "Rundll32.exe shell32.dll,Control_RunDLL timedate.cpl"
  "DateAndTimeAdditionalClocksTab" = "Rundll32.exe shell32.dll,Control_RunDLL timedate.cpl,0,1"
  "DesktopIconSettings" = "Rundll32.exe shell32.dll,Control_RunDLL desk.cpl,0,0"
  "DesktopIcons" = "Rundll32.exe shell32.dll,Control_RunDLL desk.cpl,0,0"
  "DeviceInstallationSettings" = "Rundll32.exe %SystemRoot%\System32\newdev.dll,DeviceInternetSettingUi"
  "DeviceManager" = "Rundll32.exe devmgr.dll DeviceManager_Execute"
  "DisplaySettings" = "Rundll32.exe shell32.dll,Control_RunDLL desk.cpl"
  "EaseOfAccessCenter" = "Rundll32.exe shell32.dll,Control_RunDLL access.cpl"
  "EnvironmentVariables" = "Rundll32.exe sysdm.cpl,EditEnvironmentVariables"
  "FileExplorerOptionsGeneralTab" = "Rundll32.exe shell32.dll,Options_RunDLL 0"
  "FileExplorerOptionsSearchTab" = "Rundll32.exe shell32.dll,Options_RunDLL 2"
  "FileExplorerOptionsViewTab" = "Rundll32.exe shell32.dll,Options_RunDLL 7"
  "Firewall" = "Rundll32.exe shell32.dll,Control_RunDLL firewall.cpl"
  "FontsFolder" = "Rundll32.exe shell32.dll,SHHelpShortcuts_RunDLL FontsFolder"
  "ForgottenPasswordWizard" = "Rundll32.exe keymgr.dll,PRShowSaveWizardExW"
  "GameControllers" = "Rundll32.exe shell32.dll,Control_RunDLL joy.cpl"
  "HibernateOrSleep" = "Rundll32.exe powrprof.dll,SetSuspendState"
  "IndexingOptions" = "Rundll32.exe shell32.dll,Control_RunDLL srchadmin.dll"
  "Infrared" = "Rundll32.exe shell32.dll,Control_RunDLL irprops.cpl"
  "InputLanguage" = "Rundll32.exe Shell32.dll,Control_RunDLL input.dll,0,{C07337D3-DB2C-4D0B-9A93-B722A6C106E2}"
  "InternetExplorerDeleteAllBrowsingHistory" = "Rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 255"
  "InternetExplorerDeleteAllBrowsingHistoryAndAddOnsHistory" = "Rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 4351"
  "InternetExplorerDeleteCookiesAndWebsiteData" = "Rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 2"
  "InternetExplorerDeleteDownloadHistory" = "Rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 16384"
  "InternetExplorerDeleteFormData" = "Rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 16"
  "InternetExplorerDeleteHistory" = "Rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 1"
  "InternetExplorerDeletePasswords" = "Rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 32"
  "InternetExplorerDeleteTemporaryInternetFilesAndWebsiteFiles" = "Rundll32.exe InetCpl.cpl,ClearMyTracksByProcess 8"
  "InternetExplorerOrganizeFavorites" = "Rundll32.exe shdocvw.dll,DoOrganizeFavDlg"
  "InternetPropertiesAdvancedTab" = "Rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,0,6"
  "InternetPropertiesConnectionsTab" = "Rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,0,4"
  "InternetPropertiesContentTab" = "Rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,0,3"
  "InternetPropertiesGeneralTab" = "Rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl"
  "InternetPropertiesPrivacyTab" = "Rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,0,2"
  "InternetPropertiesProgramsTab" = "Rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,0,5"
  "InternetPropertiesSecurityTab" = "Rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,0,1"
  "KeyboardProperties" = "Rundll32.exe shell32.dll,Control_RunDLL main.cpl @1"
  "LockPc" = "Rundll32.exe user32.dll,LockWorkStation"
  "MapNetworkDriveWizard" = "Rundll32.exe shell32.dll,SHHelpShortcuts_RunDLL Connect"
  'MouseOptions' = "Rundll32.exe shell32.dll,Control_RunDLL main.cpl"
  # "MouseButtonSwapLeftAndRightButtonFunction" = "Rundll32.exe user32.dll,SwapMouseButton"
  "NetworkConnections" = "Rundll32.exe shell32.dll,Control_RunDLL ncpa.cpl"
  "OdbcDataAdministrator" = "Rundll32.exe shell32.dll,Control_RunDLL odbccp32.cpl"
  "OfflineFilesGeneralTab" = "Rundll32.exe Shell32.dll,Control_RunDLL cscui.dll,0,0"
  "PowerOptions" = "Rundll32.exe shell32.dll,Control_RunDLL powercfg.cpl"
  "PowerOptionsAdvanced"="Rundll32.exe shell32.dll,Control_RunDLL powercfg.cpl,0,3"
  # we can find more definition from here
  # https://learn.microsoft.com/en-us/windows/win32/shell/controlpanel-canonical-names
  "PowerOptionsButtons"="control /name Microsoft.PowerOptions /page pageGlobalSettings"
  "PowerOptionsPlanSettings"="control /name Microsoft.PowerOptions /page pagePlanSettings"
  "Profiles" = "rundll32.exe sysdm.cpl, EditUserProfiles"
  "ProgramsAndFeatures" = "Rundll32.exe shell32.dll,Control_RunDLL appwiz.cpl,0,0"
  "Region" = "Rundll32.exe shell32.dll,Control_RunDLL Intl.cpl,0,0"
  "ScreenSaver" = "Rundll32.exe shell32.dll,Control_RunDLL desk.cpl,0,1"
  "SecurityAndMaintenance" = "Rundll32.exe shell32.dll,Control_RunDLL wscui.cpl"
  "Sound" = "Rundll32.exe shell32.dll,Control_RunDLL Mmsys.cpl,0,0"
  "StartupApps" = "Start-Process 'ms-settings:startupapps'"
  "SystemProperties" = "Rundll32.exe shell32.dll,Control_RunDLL Sysdm.cpl,0,3"
  "Taskbar" = "Rundll32.exe shell32.dll,Options_RunDLL 1"
  "UserAccounts" = "Rundll32.exe shell32.dll,Control_RunDLL nusrmgr.cpl"
  "WindowsToGoStartupOptions" = "Rundll32.exe pwlauncher.dll,ShowPortableWorkspaceLauncherConfigurationUX"
}
function Open-SystemSetting {
  [Alias("opss")]
  param (
      [Parameter(Mandatory=$true)]
      [string]$Setting
  )

  if ($commands.ContainsKey($Setting)) {
      Invoke-Expression $commands[$Setting]
  } else {
      Write-Host "Invalid setting. Available options are: `n$($commands.Keys -join ', ')"
  }
}

# Dynamic Tab Completion
Register-ArgumentCompleter -CommandName Open-SystemSetting,opss -ParameterName Setting -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
  $commands.Keys -like "$wordToComplete*"
}