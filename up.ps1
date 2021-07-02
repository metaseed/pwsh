using module Metaseed.Utility
# .local file only exist local and igored in .gitignore file
# used to prevent upgrade
if(Test-Path "$PSScriptRoot\.local") {return}

$localInfo = "$PSScriptRoot\info.json"
$days = ((Get-Date) - (gi $localInfo).LastWriteTime).Days
if($days -gt 7) {
    (gi $localInfo).LastWriteTime = Get-Date
    Update-Installation $localInfo 'https://raw.githubusercontent.com/metasong/pwsh/master/info.json' 'https://pwsh.page.link/0'
}
