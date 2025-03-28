# make the lf to use current config
$backup = "$PSScriptRoot\_Config\*"
$location = "$env:LOCALAPPDATA\lf"
Copy-Item  $backup $location -Force -Recurse