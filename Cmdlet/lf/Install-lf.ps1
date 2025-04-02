[CmdletBinding()]
param()
# ipmo Metaseed.Management -Force
Install-FromGithub https://github.com/gokcehan/lf '-windows-amd64\.zip$' -versionType 'preview' #-tofolder # -Force -Verbose

# Restore-LfConfig # not used after we setup the config env var
# note the config file is stored in the 'ConfigHome/lf', if not set, it's "$env:LOCALAPPDATA\lf"
[System.Environment]::SetEnvironmentVariable('LF_CONFIG_HOME', "$PSScriptRoot\_config",'User')
$env:LF_CONFIG_HOME = "$PSScriptRoot\_config"