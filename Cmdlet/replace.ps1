$match = "ModuleTemplate" 
$replacement = Read-Host "Please enter a Module name"

$files = Get-ChildItem $(get-location) -filter *ModuleTemplate* -Recurse

$files |
Sort-Object -Descending -Property FullName |
Rename-Item -newname { $_.name -replace $match, $replacement } -force


Get-ChildItem $(get-location) -include *.cs, *.csproj, *.sln, *.resx, *.targets, *.xml, *.config, *.xaml -Recurse |
% {((Get-Content $_.fullname -Encoding UTF8) -creplace $match, $replacement)} |
set-content $file.fullname -Encoding UTF8

read-host -prompt "Done! Press any key to close."