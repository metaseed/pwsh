# https://megamorf.gitlab.io/cheat-sheets/powershell-psreadline/
# C:\Program Files\PowerShell\7\Modules\PSReadLine\SamplePSReadLineProfile.ps1
$PSReadLineOptions = @{
    # Prevent annoying beeping noises (e.g. when pressing backspace on empty line)
    BellStyle = "None" 
    # HistorySearchCursorMovesToEnd = $true
    MaximumHistoryCount = 10000
}
Set-PSReadLineOption @PSReadLineOptions

Set-PSReadlineKeyHandler -Chord Alt+F4 -Function ViExit
# not work in vscode
Set-PSReadlineKeyHandler -Chord Ctrl+Shift+K -Function DeleteLine 
#not work in vscode
Set-PSReadlineKeyHandler -Key Shift+Alt+C `
    -BriefDescription CopyPathToClipboard `
    -LongDescription "Copies the current path to the clipboard.(gl).path|scb" `
    -ScriptBlock { (Resolve-Path -LiteralPath $pwd).ProviderPath.Trim() | scb } #if using clip, gcb would return a string array: [the-path, ''] 

<#
Get-PSReadLineKeyHandler -Bound -Unbound
tips:
remove cmd history: Remove-Item (Get-PSReadlineOption).HistorySavePath
Ctrl+]: goto Brace
ctrl-l: clear screen
alt-.: last argument of previous command
ctrl-space: MenuComplete
#>