# $os = gcim Win32_OperatingSystem
# $osVersion = [Version]::new($os.version)
# if($osVersion -ge [Version]::new('10.0.22000')) { # win11
#   winget install python
#   return
# }
if(gcm winget -ErrorAction Ignore) {
  winget install python
  return
}

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
& $env:temp\python3.exe /passive