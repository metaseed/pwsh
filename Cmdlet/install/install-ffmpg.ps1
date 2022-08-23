
# https://ffmpeg.org/download.html#build-windows
# https://github.com/GyanD/codexffmpeg/releases/
[CmdletBinding()]
param()

Install-FromGithub 'GyanD' 'codexffmpeg' '-full_build.zip$' -app 'ffmpeg'

