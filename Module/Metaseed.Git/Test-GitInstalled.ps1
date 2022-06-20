function Test-GitInstalled {
  [CmdletBinding()]
  Param()

  # Registry keys potentially containing Git installation details
  $GitRegistryKeys = @(
      # User
      'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1',
      # Machine: Native bitness
      'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1',
      # Machine: x86 on x64
      'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1'
  )

  # Registry property which contains the installation directory
  $GitInstallProperty = 'InstallLocation'

  foreach ($RegKey in $GitRegistryKeys) {
      $GitInstallPath = (Get-ItemProperty -Path $RegKey -ErrorAction Ignore).$GitInstallProperty

      if ($GitInstallPath) {
          break
      }
  }

  if (!$GitInstallPath) {
      throw 'Unable to locate a Git installation.'
  }

  if (!(Test-Path -Path $GitInstallPath -PathType Container)) {
      throw 'The Git installation directory does not exist.'
  }

  return $GitInstallPath
}