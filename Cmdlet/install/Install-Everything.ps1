[CmdletBinding()]
param (
  [Parameter()]
  [switch]
  $force
)
import-Module metaseed.utility -Force
Install-FromWeb 'https://www.voidtools.com/downloads' '<a .*href="(.*)".*>\s*Download Portable Zip 64-bit' -force:$force -restoreList @('everything.ini') -toLocation $env:MS_App\software

Install-FromWeb 'https://www.voidtools.com/downloads' '<a .*href="(.*)".*>\s*ES-\d+\.\d+\.?\d*\.?\d*.*\.zip' -force:$true -newName everything-cmd
