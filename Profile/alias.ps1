Set-Alias ga Get-Alias
Set-Alias ghp Get-Help # gh collide with gh.exe github cli
Set-Alias ca Compress-Archive
Set-Alias sa Start-Process # default: saps, start
Set-Alias np New-ItemProperty # rp: Remove-ItemProperty; gp: Get-ItemProperty

Set-Alias c cursor

. $PSScriptRoot\..\Cmdlet\_\alias.ps1

# "C:\Users\metaseed\AppData\Local\Programs\Microsoft VS Code Insiders\Code - Insiders.exe"
# perf: -Type Application avoids searching aliases/functions/cmdlets (~13ms saved);
#       only runs the fallback branch when 'code' is absent
if (-not (Get-Command code -Type Application -ErrorAction Ignore)) {
    if (Get-Command 'code-insiders' -Type Application -ErrorAction Ignore) {
        Set-Alias code code-insiders -Scope Global
    }
}

## share data
# use to store permanent values. share data or value between sessions:
# compare with ram disk and mem mapped files, the registry is also mem buffered and persistent, faster to share small objects
# no need to worry ram wasting(initial size, persistent or releasing), and releasing between sessions (memMappedFile is released when no reference to it)

## usage:
# ni r:a # create subKey `a`
# np r:a myKey -v 1 # new prop `myKey`
# gp r:a myKey # get prop `myKey`
# gpv r:a myKey # get prop value only
# sp r:a myKey -v value # set prop value
# rp r:a myKey # remove
# ri r:a # clear all
# perf: use -ErrorAction Ignore instead of Test-Path; Test-Path "HKCU:\..." triggers
#       a full registry provider init (~60ms), direct create with Ignore avoids that
$null = New-Item -Path "HKCU:\MS_PWSH" -ErrorAction Ignore
$null = New-PSDrive -Name R -PSProvider Registry -Root "HKCU:\MS_PWSH" -ErrorAction Ignore
