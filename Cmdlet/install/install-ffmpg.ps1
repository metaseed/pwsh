
# https://ffmpeg.org/download.html#build-windows
# https://github.com/GyanD/codexffmpeg/releases/
[CmdletBinding()]
param()

Install-FromGithub 'GyanD/codexffmpeg' '-full_build.zip$' -application 'ffmpeg'

New-Item -ItemType HardLink -Path $env:MS_App\_shim\ffmpeg.exe -Value c:\app\ffmpeg\bin\ffmpeg.exe -Force
New-Item -ItemType HardLink -Path $env:MS_App\_shim\ffplay.exe -Value c:\app\ffmpeg\bin\ffplay.exe -Force
New-Item -ItemType HardLink -Path $env:MS_App\_shim\ffprobe.exe -Value c:\app\ffmpeg\bin\ffprobe.exe -Force
# fsutil hardlink list c:\app\_shim\ffmpeg.exe