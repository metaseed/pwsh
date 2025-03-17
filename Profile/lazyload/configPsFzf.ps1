# https://github.dev/kelleyma49/PSFzf

# dependency:
# https://github.com/junegunn/fzf
# https://github.com/powercode/PSEverything
# https://git-scm.com/downloads

Set-PsFzfOption `
-PSReadlineChordSetLocation 'Alt+d'  <# find dir from current dir/subdir and setLocation to it #> `
-PSReadlineChordReverseHistoryArgs 'Alt+a'  <# find arg from input history#> `
-PSReadlineChordProvider 'Alt+f' <# find file/dir from current dir/subdir or the dir at current cursor, i.e.: cd m:app(|cursor here) and then press a-f, type soft, <enter> <enter> cd to the software folder#> `
-PSReadlineChordReverseHistory 'Alt+r' <# find full line input from input history#>
# -EnableAliasFuzzyZLocation `
# -EnableAliasFuzzySetEverything

Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
# Set-PSReadLineKeyHandler -Key 'Alt+a' -ScriptBlock { Invoke-FzfPsReadlineHandlerHistoryArgs } -Description 'Run fzf to search through command line arguments in PSReadline history'
# Set-PSReadLineKeyHandler -Key 'Alt+d' -ScriptBlock { Invoke-FzfPsReadlineHandlerSetLocation } -Description 'Run fzf to select directory to set current location'
# Set-PSReadLineKeyHandler -Key 'Alt+h' -ScriptBlock { Invoke-FzfPsReadlineHandlerHistory } -Description 'Run fzf to search through PSReadline history'
# Set-PSReadLineKeyHandler -Key 'Alt+f' -ScriptBlock { Invoke-FzfPsReadlineHandlerProvider } -Description 'Run fzf for current provider based on current token'

Set-Alias ifz    -Scope global Invoke-Fzf

# edit the found dir/file with vscode(windows default is vscode)
Set-Alias fe     -Scope global Invoke-FuzzyEdit
# find cmd from file: (Get-PSReadlineOption).HistorySavePath
Set-Alias fh     -Scope global Invoke-FuzzyHistory
# Set-Alias ff     -Scope global Invoke-FuzzyFasd # requires Fasdr to be previously installed under Windows.
# fuzzy/faster kill
Set-Alias fkill  -Scope global Invoke-FuzzyKillProcess

# use alt+d instead
Set-Alias slf     -Scope global Invoke-FuzzySetLocation
# cd with everything db
Set-Alias sle    -Scope global Set-LocationFuzzyEverything
# fuzzy set location with zlocation db
Set-Alias slz    -Scope global Invoke-FuzzyZLocation

# Set-Alias fs     -Scope global Invoke-FuzzyScoop
Set-Alias fgs    -Scope global Invoke-FuzzyGitStatus
Set-Alias fgf    -Scope global Invoke-FuzzyGitFiles
Set-Alias fgh    -Scope global Invoke-FuzzyGitHashes
Set-Alias fgt    -Scope global Invoke-FuzzyGitTags
Set-Alias fgst    -Scope global Invoke-FuzzyGitStashes
Set-Alias fgb    -Scope global Invoke-PsFzfGitBranches

<#
tab completion for git, gps,saps, gsv, spsv
i.e. gps <tab>code
#>

