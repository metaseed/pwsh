# https://github.dev/nightroman/PS-GuiCompletion

Import-Module GuiCompletion -ErrorAction Ignore
if(!$?) {
  Install-Module -Name GuiCompletion -Scope CurrentUser -Force
}
$GuiCompletionConfig.DoubleBorder = $false
# $GuiCompletionConfig.AutoExpandOnDot = $true
Install-GuiCompletion -Key Tab
