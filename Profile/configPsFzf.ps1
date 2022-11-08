# https://github.dev/kelleyma49/PSFzf
Set-PsFzfOption -EnableAliasFuzzyZLocation `
-EnableAliasFuzzySetEverything `
-PSReadlineChordProvider 'Alt+t' -PSReadlineChordReverseHistory 'Alt+r' -PSReadlineChordSetLocation 'Alt+c' -PSReadlineChordReverseHistoryArgs 'Alt+a'
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

