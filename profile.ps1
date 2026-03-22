# note: auto-setup in config.ps1

# include this file in $profile:
# notepad $profile.CurrentUserAllHosts
# . m:\script\pwsh\profile.ps1

# note: reload profile if modified codes in this repo
# . $profile.CurrentUserAllHosts # should not use & as it will hide some var updating

. $PSScriptRoot\profile\main.ps1
. $PSScriptRoot\update.ps1 -days 3

# pixi auto completion
(& pixi completion --shell powershell) | Out-String | Invoke-Expression