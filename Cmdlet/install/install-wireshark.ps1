[CmdletBinding()]
param (
  [Parameter()]
  [switch]
  $force
)
import-Module metaseed.utility -Force

# note : not work, find a earlier version
Install-FromWeb 'https://www.wireshark.org/download.html' '<a .*href="(https.*win64\/WiresharkPortable64_.*\.paf\.exe)".*>.*Windows x64 PortableApps' -force:$true -newName wireshark
