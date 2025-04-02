# copy the current config of `lf` in _config/lf dir into  "$env:LOCALAPPDATA\lf"
# we have setup the 'LF_CONFIG_HOME' env var, so this script is not needed

$backup = "$PSScriptRoot\_Config\lf\*"
$location = "$env:LOCALAPPDATA\lf"
Copy-Item  $backup $location -Force -Recurse
