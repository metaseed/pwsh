[CmdletBinding()]
param (
    [Parameter()]
    [string]
    [Alias("v")]
    $Version = 'latest'
)

# install pwsh 7
if ($PSVersionTable.PSVersion.Major -lt 7) {
    write-error "please install powershell version great than 7"
    write-host "https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows"
    Write-host 'please install it and run this script again in the new powershell' -ForegroundColor Blue

    return
}

Set-ExecutionPolicy Bypass -Scope Process -Force

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
"install ms_pwsh ver: $Version..."
$zip = "$env:temp/pwsh.zip"
if ($Version -eq 'latest') {
    $url = 'http://github.com/metasong/pwsh/archive/refs/heads/master.zip'
}
else {
    $url = "https://github.com/metasong/pwsh/archive/refs/tags/$Version.zip" #1.0.2
}
iwr $url -OutFile $zip
#
# ~ is better than $env:HomePath, it include the home drive, just like $home
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
