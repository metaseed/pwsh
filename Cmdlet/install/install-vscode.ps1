# Import-Module metaseed.Utility  -DisableNameChecking
$file = Get-RedirectedUrl "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64"
$Exe = Get-RemoteFile $file
# Install with the context menu, file association, and add to path options (and don't run code after install:
$installerArguments = '/silent /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'
'>>>>>> Installing vscode, this would take a while, please wait...'
Start-Process  $Exe -ArgumentList $installerArguments -NoNewWindow -Wait
#on none-ui-windows: need to repoen taskmanager(update path) then run powershell, to invoke `code` command