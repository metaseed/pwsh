
# Import-Module Metaseed.Management -Force
# Install-FromSourceForge -project "exiftool" -filePattern "*_64.zip" @args

ni -ItemType HardLink c:\app\exiftool\exiftool.exe -Value 'c:\app\exiftool\exiftool(-k).exe' -Force
Add-PathEnv c:\app\exiftool