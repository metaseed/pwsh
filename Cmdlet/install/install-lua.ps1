
# Import-Module Metaseed.Management -Force
Install-FromSourceForge -project "luabinaries" -newName 'lua' -filePattern "*_Win64_bin.zip" @args

Add-PathEnv c:/app/lua
