$backup = "$PSScriptRoot\Config\*"
$location = "$env:LOCALAPPDATA\lf"
Copy-Item  $backup $location -Force -Recurse