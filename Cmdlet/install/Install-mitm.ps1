[CmdletBinding()]
param (
  [Parameter()]
  [switch]
  $force
)
Import-Module metaseed.utility -Force
Import-Module Metaseed.Management -Force

# Use GitHub release tag for latest version (for example: v12.2.2).
$ver = (Invoke-RestMethod https://api.github.com/repos/mitmproxy/mitmproxy/releases/latest).tag_name #v12.2.2
$latest = "$ver".TrimStart('v')

if (!$latest) {
  Write-Error 'Could not determine the latest mitmproxy version from GitHub releases.'
  return
}

# Reuse Install-FromWeb against mitmproxy's S3 XML listing for the selected version.
# not the '/' after the version is important. without it we can not get the url of downloadable file.
Install-FromWeb "https://downloads.mitmproxy.org/list?delimiter=/&prefix=$latest/" "<Key>($latest/mitmproxy-$latest-windows-x86_64\.zip)</Key>" -force:$force -toLocation $env:MS_App -newName mitmproxy
