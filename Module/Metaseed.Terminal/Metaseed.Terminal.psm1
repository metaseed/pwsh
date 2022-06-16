# Import-Module $PSScriptRoot/_bin/TerminalBackground.dll
Initialize-WTBgImg
# could not export any function via Export-ModuleMember, so put it psd1
# . $env:MS_PWSH/Lib/Export-Functions.ps1
# . Export-Functions $PSScriptRoot
. $PSScriptRoot/Terminal/Play-WTBGGif.ps1
