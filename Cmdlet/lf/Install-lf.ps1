[CmdletBinding()]
param()
# ipmo Metaseed.Management -Force
Install-FromGithub 'gokcehan/lf' '-windows-amd64\.zip$' -versionType 'preview' -tofolder # -Force -Verbose

