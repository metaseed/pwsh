[CmdletBinding()]
param (
    [Parameter()]
    [string]
    [Alias("v")]
    $Version = 'latest'
)

Set-ExecutionPolicy Bypass -Scope Process -Force

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "[Wait] download ms_pwsh version: $Version ..."
$zip = "$env:temp/pwsh.zip"
if ($Version -eq 'latest') {
    $url = 'http://github.com/metasong/pwsh/archive/refs/heads/master.zip'
}
else {
    $url = "https://github.com/metasong/pwsh/archive/refs/tags/$Version.zip" #1.0.2
}
$pro = $ProgressPreference
$ProgressPreference = 'SilentlyContinue' # imporve iwr speed
iwr $url -OutFile $zip
$ProgressPreference = $pro
#
# ~ is better than $env:HomePath, it include the home drive, just like $home
Write-Host "install ms_pwsh..."
Expand-Archive $zip ~/metaseed -Force

# directly ri the pwsh folder may cause error if it is used.
# mi works even file is used
# but mi would show error if des exists: because a file or directory with the same name already exists.
# the .ms_pwsh-del shouldn't be used/locked by any app
ri '~/metaseed/.ms_pwsh-del' -Force -Recurse -ErrorAction SilentlyContinue
mi '~/metaseed/ms_pwsh' '~/metaseed/.ms_pwsh-del' -Force -ErrorAction SilentlyContinue
ri '~/metaseed/.ms_pwsh-del' -Force -Recurse -ErrorAction SilentlyContinue
ri $zip -Force

. '~/metaseed/pwsh-master/config.ps1'
