[CmdletBinding()]
param (
  [Parameter()]
  [switch]
  $force
)
import-Module metaseed.utility -Force
import-Module Metaseed.Management -Force

Install-FromWeb 'https://www.voidtools.com/downloads' '<a .*href="(.*)".*>\s*Download Portable Zip 64-bit' -force:$force -restoreList @('everything.ini') -toLocation $env:MS_App\software

ni -type hardlink -value M:\App\software\Everything\everything.exe  M:\App\_shim\everything.exe

Install-FromWeb 'https://www.voidtools.com/downloads' '<a .*href="(.*)".*>\s*ES-\d+\.\d+\.?\d*\.?\d*.*\.zip' -force:$true -newName everything-cmd
