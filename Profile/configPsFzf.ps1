# https://github.dev/kelleyma49/PSFzf

# dependency:
# https://github.com/junegunn/fzf
# https://github.com/powercode/PSEverything
# https://git-scm.com/downloads

Set-PsFzfOption `
-PSReadlineChordSetLocation 'Alt+d' `
-PSReadlineChordReverseHistoryArgs 'Alt+a' `
-PSReadlineChordProvider 'Alt+f' `
-PSReadlineChordReverseHistory 'Alt+r'
# -EnableAliasFuzzyZLocation `
# -EnableAliasFuzzySetEverything

Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
# Set-PSReadLineKeyHandler -Key 'Alt+a' -ScriptBlock { Invoke-FzfPsReadlineHandlerHistoryArgs } -Description 'Run fzf to search through command line arguments in PSReadline history'
# Set-PSReadLineKeyHandler -Key 'Alt+d' -ScriptBlock { Invoke-FzfPsReadlineHandlerSetLocation } -Description 'Run fzf to select directory to set current location'
# Set-PSReadLineKeyHandler -Key 'Alt+h' -ScriptBlock { Invoke-FzfPsReadlineHandlerHistory } -Description 'Run fzf to search through PSReadline history'
# Set-PSReadLineKeyHandler -Key 'Alt+f' -ScriptBlock { Invoke-FzfPsReadlineHandlerProvider } -Description 'Run fzf for current provider based on current token'

Set-Alias ifz    -Scope global Invoke-Fzf

Set-Alias fe     -Scope global Invoke-FuzzyEdit
Set-Alias fh     -Scope global Invoke-FuzzyHistory
# Set-Alias ff     -Scope global Invoke-FuzzyFasd
Set-Alias fkill  -Scope global Invoke-FuzzyKillProcess
# Set-Alias fd     -Scope global Invoke-FuzzySetLocation # use alt+d instead
Set-Alias cde    -Scope global Set-LocationFuzzyEverything
Set-Alias cdz    -Scope global Invoke-FuzzyZLocation
# Set-Alias fs     -Scope global Invoke-FuzzyScoop
Set-Alias fgs    -Scope global Invoke-FuzzyGitStatus
Set-Alias fgf    -Scope global Invoke-FuzzyGitFiles
Set-Alias fgh    -Scope global Invoke-FuzzyGitHashes
Set-Alias fgt    -Scope global Invoke-FuzzyGitTags
Set-Alias fgst    -Scope global Invoke-FuzzyGitStashes
Set-Alias fgb    -Scope global Invoke-PsFzfGitBranches

