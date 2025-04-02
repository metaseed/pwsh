# make the lf to use current config in _config dir, by default it's in "$env:LOCALAPPDATA\lf"
# $backup = "$PSScriptRoot\_Config\lf\*"
# $location = "$env:LOCALAPPDATA\lf"
# Copy-Item  $backup $location -Force -Recurse

[System.Environment]::SetEnvironmentVariable('LF_CONFIG_HOME', "$PSScriptRoot\_config",'User')
$env:LF_CONFIG_HOME = "$PSScriptRoot\_config"