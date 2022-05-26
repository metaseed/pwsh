# https://megamorf.gitlab.io/cheat-sheets/powershell-psreadline/
# C:\Program Files\PowerShell\7\Modules\PSReadLine\SamplePSReadLineProfile.ps1
$PSReadLineOptions = @{
    # respond to errors or conditions that require user attention.
    # Prevent annoying beeping noises (e.g. when pressing backspace on empty line)
    # BellStyle           = "None" 
    # HistorySearchCursorMovesToEnd = $true
    MaximumHistoryCount = 10000
}
# https://docs.microsoft.com/en-us/powershell/module/psreadline/set-psreadlineoption?view=powershell-7.2
Set-PSReadLineOption @PSReadLineOptions

# https://docs.microsoft.com/en-us/powershell/module/psreadline/set-psreadlinekeyhandler?view=powershell-7.2
Set-PSReadlineKeyHandler -Chord Alt+F4 -Function ViExit
# not work in vscode
Set-PSReadlineKeyHandler -Chord Ctrl+Shift+K -Function DeleteLine 
#not work in vscode
Set-PSReadlineKeyHandler -Key Shift+Alt+C `
    -BriefDescription CopyPathToClipboard `
    -LongDescription "Copies the current path to the clipboard.(gl).path|scb" `
    -ScriptBlock { (Resolve-Path -LiteralPath $pwd).ProviderPath.Trim() | scb } #if using clip, gcb would return a string array: [the-path, ''] 

Set-PSReadlineKeyHandler -Key Enter -ScriptBlock { 
    $line = $cursor = $null
    # https://stackoverflow.com/questions/67136144/getting-powershell-current-line-before-enter-is-pressed
    # cursor is the cursor position in the line, start from 0
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $line, [ref] $cursor)
    if ($line -match '^\s*(Replay-Steps|rs$)') {
        $Steps = $global:__Session.Steps
    } else {
        $Steps = @()
    }
    # session scale variable
    # used in write-step/substep/execute
    $global:__Session = @{
        Steps =$Steps
    }

    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

<#
Get-PSReadLineKeyHandler -Bound -Unbound
tips:
remove cmd history: Remove-Item (Get-PSReadlineOption).HistorySavePath
Ctrl+]: goto Brace
ctrl-l: clear screen
alt-.: last argument of previous command
ctrl-space: MenuComplete
#>
