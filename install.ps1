[CmdletBinding()]
param (
    [Parameter()]
    [string]
    [Alias("v")]
    $Version = 'latest'
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
"install ms_pwsh ver: $Version..."
$zip = "$env:temp/pwsh.zip"
if($Version -eq 'latest') {
    $unzipped = 'pwsh-master'
    $url ='http://github.com/metasong/pwsh/archive/refs/heads/master.zip'
} else {
    $unzipped = "pwsh-$Version"
    $url = "https://github.com/metasong/pwsh/archive/refs/tags/$Version.zip" #1.0.2
}
iwr $url -OutFile $zip
# 
# ~ is better than $env:HomePath, it include the home drive
Expand-Archive $zip ~/metaseed -Force

# directly ri the pwsh folder may cause error if it is used.
# mi works even file is used
# but mi would show error if des exists: because a file or directory with the same name already exists.
# the .ms_pwsh-del shouldn't be used/locked by any app
ri ~/metaseed/.ms_pwsh-del -Force -Recurse -ErrorAction SilentlyContinue
mi ~/metaseed/ms_pwsh ~/metaseed/.ms_pwsh-del -Force -ErrorAction SilentlyContinue
ri ~/metaseed/.ms_pwsh-del -Force -Recurse -ErrorAction SilentlyContinue

mi "~/metaseed/$unzipped" ~/metaseed/ms_pwsh -Force

. ~/metaseed/ms_pwsh/config.ps1
