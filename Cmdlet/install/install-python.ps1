# $os = gcim Win32_OperatingSystem
# $osVersion = [Version]::new($os.version)
# if($osVersion -ge [Version]::new('10.0.22000')) { # win11
#   winget install python
#   return
# }

# the winget not update the latest version faster. i.e. ver3.11 is release on oct 24, 2022, but on nov 2, 2022 it's still 3.10
# if(gcm winget -ErrorAction Ignore) {
#   winget install python
#   return
# }

$resp = iwr https://www.python.org/downloads/windows/
$content = $resp.content
$content -match 'href="(.+)">Latest Python' > $null
$part = $matches[1]
$resp = iwr "https://www.python.org$part"
$content = $resp.content
$content -match 'href="(.+)">Windows installer \(64-bit\)' > $null
$url = $matches[1]
# https://www.python.org/ftp/python/3.10.5/python-3.10.5-amd64.exe
iwr $url -OutFile $env:temp\python3.exe
# & $env:temp\python3.exe /h
# passive to prevent user customization
# https://docs.python.org/3.6/using/windows.html#installing-without-ui
$path = "$env:temp\python3.exe"
write-host "install python from $path , please wait..."
Start-Process -Wait $path "/quiet InstallAllUsers=1 PrependPath=1"
write-host "down!"