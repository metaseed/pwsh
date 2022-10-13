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

iwr https://www.python.org/ftp/python/3.10.5/python-3.10.5-amd64.exe -OutFile $env:temp\python3.exe
# & $env:temp\python3.exe /h
# passive to prevent user customization
& $env:temp\python3.exe /passive