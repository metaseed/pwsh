Set-Alias ga Get-Alias
Set-Alias ghp Get-Help # gh collide with gh.exe github cli
Set-Alias ca Compress-Archive
Set-Alias sa Start-Process # default: saps, start
Set-Alias np New-ItemProperty # rp: Remove-ItemProperty; gp: Get-ItemProperty
. $PSScriptRoot\..\Cmdlet\_\alias.ps1

& { # prevent $codePath leak in to profile variable: provider
    $codePath = (Get-Command code -ErrorAction Ignore).Source
    if ($null -eq $codePath) {
        $codePath = (Get-Command 'code-insiders' -ErrorAction Ignore).Source
        if ($null -ne $codePath) {
            # "C:\Users\metaseed\AppData\Local\Programs\Microsoft VS Code Insiders\Code - Insiders.exe"
            Set-Alias code code-insiders -Scope Global
        }
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
# rp r:a myKey # remove
# ri r:a # clear all
if (-not (Test-Path "HKCU:\MS_PWSH")) {
    New-Item -Path "HKCU:\MS_PWSH"
}
if (!(Test-Path 'R:')) {
    New-PSDrive -Name R -PSProvider Registry -Root "HKCU:\MS_PWSH" > $null
}
