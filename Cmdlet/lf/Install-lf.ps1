[CmdletBinding()]
param()
# ipmo Metaseed.Management -Force
Install-FromGithub https://github.com/gokcehan/lf '-windows-amd64\.zip$' -versionType 'preview' -tofolder # -Force -Verbose

Restore-LfConfig