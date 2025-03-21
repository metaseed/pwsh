# https://megamorf.gitlab.io/cheat-sheets/powershell-psreadline/
# C:\Program Files\PowerShell\7\Modules\PSReadLine\SamplePSReadLineProfile.ps1
$PSReadLineOptions = @{
    # respond to errors or conditions that require user attention.
    # Prevent annoying beeping noises (e.g. when pressing backspace on empty line)
    # BellStyle           = "None"
    # HistorySearchCursorMovesToEnd = $true
    MaximumHistoryCount = 10000
    # Set-PSReadLineOption -Colors @{ "ListPrediction" = "`e[90m" }
    Colors              = @{ "ListPrediction" = "`e[90m" }
    PredictionViewStyle = 'ListView'
}
# https://docs.microsoft.com/en-us/powershell/module/psreadline/set-psreadlineoption?view=powershell-7.2
Set-PSReadLineOption @PSReadLineOptions

# also work
# $options = Get-PSReadLineOption
# $options.ListPredictionColor = "`e[90m" # original value "`e[33m"

# https://docs.microsoft.com/en-us/powershell/module/psreadline/set-psreadlinekeyhandler?view=powershell-7.2
Set-PSReadlineKeyHandler -Chord Alt+F4 -Function ViExit

# not work in vscode
# ctrl+enter to add a new line, `esc` to cancel all input, not only the current line.
Set-PSReadlineKeyHandler -Chord Ctrl+Shift+K -Function DeleteLine

# not work in vscode
Set-PSReadlineKeyHandler -Key Shift+Alt+C `
    -BriefDescription CopyPathToClipboard `
    -LongDescription "Copies the current path to the clipboard.(gl).path|scb" `
    -ScriptBlock { (Resolve-Path -LiteralPath $pwd).ProviderPath.Trim() | scb } #if using clip, gcb would return a string array: [the-path, '']

Set-PSReadlineKeyHandler -Key Enter -ScriptBlock {
    # session scale variables
    # __SetStepSessionVariables
    # https://stackoverflow.com/questions/67136144/getting-powershell-current-line-before-enter-is-pressed
    # cursor is the cursor position in the line, start from 0
    $line = $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $line, [ref] $cursor)
    $lastSessionScope = $global:__PSReadLineSessionScope
    $global:__PSReadLineSessionScope = @{SessionStartTime = [datetime]::Now; LastSessionStartTime = ($lastSessionScope.SessionStartTime ?? [datetime]::Now) }
    # create a scope for a psReadline session
    New-Event -SourceIdentifier 'PSReadlineSessionScopeEvent' -EventArguments @{
        scope     = $global:__PSReadLineSessionScope;
        lastScope = $lastSessionScope;
        line      = $line;
        cursor    = $cursor;
    }

    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# like open dialog to select one or more file dir
Set-PSReadLineKeyHandler -Chord Ctrl+o -ScriptBlock { #Ctrl+Shift+o Ctrl+d  work
    lf -lastSelection
}
# like save dialog to chose a dir
Set-PSReadLineKeyHandler -Chord Ctrl+s -ScriptBlock {
    # to accept the returned path as argument to current command
    # [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine() # clear current buffer
    # [Microsoft.PowerShell.PSConsoleReadLine]::Insert('(a lf)') # input
    # [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() # execute
    # Import-Module Metaseed.Utility -DisableNameChecking
    #a lf
    lf
}



# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
#     # https://github.dev/PowerShell/PSReadLine/blob/master/PSReadLine/Completion.cs
#     # https://github.dev/nightroman/PS-GuiCompletion
#     # https://powershellone.wordpress.com/2015/10/07/expanding-aliases-in-powershell-ise-or-any-powershell-file/

#     [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext()
# }

<#
Get-PSReadLineKeyHandler -Bound -Unbound
Ctrl+s    ForwardSearchHistory    Search history forward interactively
Ctrl+r    ReverseSearchHistory    Search history backwards interactively

tips:
remove cmd history: Remove-Item (Get-PSReadlineOption).HistorySavePath
Ctrl+]: goto Brace
ctrl-l: clear screen
alt-.: last argument of previous command
ctrl-space: MenuComplete

#>