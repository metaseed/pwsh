# note: auto-setup in config.ps1

# include this file in $profile:
# notepad $profile.CurrentUserAllHosts
# . m:\script\pwsh\profile.ps1

# note: reload profile if modified codes in this repo
# . $profile.CurrentUserAllHosts # should not use & as it will hide some var updating
# if ($env:CURSOR_AGENT) { return } in $profile.CurrentUserAllHosts to avoid reload when in agent
. $PSScriptRoot\profile\main.ps1
. $PSScriptRoot\update.ps1 -days 3
