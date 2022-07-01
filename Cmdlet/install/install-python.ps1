iwr https://www.python.org/ftp/python/3.10.5/python-3.10.5-amd64.exe -OutFile $env:temp\python3.exe
# & $env:temp\python3.exe /h
# passive to prevent user customization
& $env:temp\python3.exe /passive