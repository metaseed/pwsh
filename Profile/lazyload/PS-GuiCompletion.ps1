# https://github.com/nightroman/PS-GuiCompletion

Import-Module GuiCompletion -ErrorAction Ignore

if(!$?) {
  Install-Module -Name GuiCompletion -Scope CurrentUser -Force
}

$GuiCompletionConfig.DoubleBorder = $false
# $GuiCompletionConfig.AutoExpandOnDot = $true
Install-GuiCompletion -Key Tab


# tips:
# $GuiCompletionConfig to view all config
# . and \ are used to further expansion when the menu is popup

# Get-PSReadlineKeyHandler to view help
# Get-PSReadLineOption to current config
# F2 to toggle inline/list view, F8: next item in history
# -> to accept prompt