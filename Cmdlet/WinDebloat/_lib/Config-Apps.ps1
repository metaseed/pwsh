[CmdletBinding()]
param (
  [Parameter()]
  [bool]
  $vm
)

if ($vm) {
  # uninstall one drive
  # C:\Users\jsong12\AppData\Local\Microsoft\OneDrive\22.181.0828.0002\OneDriveSetup.exe  /uninstall
  cmd /c (Get-ItemPropertyValue HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe UninstallString)

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
  # ? { $_.PackageName -match "Microsoft.Xbox" } |
  Uninstall-Appx $XboxApps

  @(
    '*FeedbackHub*',
    '*YourPhone*',
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
  ) | Uninstall-Appx

}
else {
  # to Permanently disable Adobe Collab Sync
  # disable the AdobeCollabSync.exe running in background.
  # https://community.adobe.com/t5/acrobat-discussions/permanently-disable-adobe-collab-sync/td-p/11733706
  Set-ItemProperty 'HKCU:\Software\Adobe\Adobe Acrobat\DC\Workflows' bNeedSynchronizer 0
}