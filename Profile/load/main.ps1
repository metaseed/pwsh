# . $PSScriptRoot\posh-git.ps1
. $PSScriptRoot\PSReadlineConfig.ps1
. $PSScriptRoot\prompt\prompt.main.ps1 # 1s; has to be after the psreadlineconfig, in starship config, transientPrompt set enter key handler
. $PSScriptRoot\terminal\terminal.ps1
. $PSScriptRoot\configPsFzf.ps1
. $PSScriptRoot\zoxide.config.ps1
. $PSScriptRoot\yazi.config.ps1
