$file = $env:f
$file = $file.trim('"')
[Diagnostics.Process]::Start('rundll32.exe', "$([Environment]::GetFolderPath('system'))\shell32.dll,OpenAs_RunDLL $file")