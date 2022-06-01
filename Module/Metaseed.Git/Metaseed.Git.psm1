# . $PSScriptRoot\..\Metaseed.Lib\_Special\Export-Functions.ps1
# https://stackoverflow.com/questions/15187510/dot-sourcing-functions-from-file-to-global-scope-inside-of-function
# need to dot source the function otherwise the file dotsourced in the Export-Functions would not be included in moudle scope
# after dotsource the function, it's the same as the function is defined here in the same file.
. Export-Functions $PSScriptRoot