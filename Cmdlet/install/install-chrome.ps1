[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $defaultBrowser
)

$url = 'http://dl.google.com/chrome/install/375.126/chrome_installer.exe'
$Installer = "$env:temp\chrome_installer.exe"
iwr -Uri $url -OutFile $Installer -UseBasicParsing
Start-Process -FilePath $Installer -Args '/silent /install' -Wait
$chromeApp = "${Env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
$chromeCommandArgs = $defaultBrowser ? "--make-default-browser" : ''
& "$chromeApp" $chromeCommandArgs