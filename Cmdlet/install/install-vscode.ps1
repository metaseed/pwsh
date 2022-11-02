# Import-Module metaseed.Utility  -DisableNameChecking
$url = Get-RedirectedUrl "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64"
# use this url also work: "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
$Exe = Get-RemoteFile $url
# Install with the context menu, file association, and add to path options (and don't run code after install:
$installerArguments = '/silent /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'
'>>>>>> Installing vscode, this would take a while, please wait...'
Start-Process  -NoNewWindow -Wait  $Exe -ArgumentList $installerArguments
#on none-ui-windows: need to repoen taskmanager(update path) then run powershell, to invoke `code` command