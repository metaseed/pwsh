
# Import-Module Metaseed.Management -Force
Install-FromGithub https://github.com/obsproject/obs-studio 'OBS-Studio-.*-Windows-x64\.zip$' -versionType 'preview'  @args
ni -Type SymbolicLink 'C:\app\_shim\obs.exe' -Value 'C:\app\obs-studio\bin\64bit\obs64.exe'