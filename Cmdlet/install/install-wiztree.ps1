[CmdletBinding()]
param (
  [Parameter()]
  [switch]
  $force
)
import-Module metaseed.utility -Force
import-Module Metaseed.Management -Force

# note : not work, find a earlier version
# href="files/wiztree_4_25_portable.zip"
Install-FromWeb 'https://diskanalyzer.com/download'  '<a .*href="(files\/wiztree_4_25_portable\.zip)".*>.*DOWNLOAD PORTABLE' -force:$true -newName wiztree

ni -Type HardLink M:\app\wiztree\size.exe -Value M:\app\wiztree\WizTree64.exe

