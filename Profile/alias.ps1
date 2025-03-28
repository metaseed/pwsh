Set-Alias ga Get-Alias
Set-Alias ghp Get-Help # gh collide with gh.exe github cli
Set-Alias ca Compress-Archive
Set-Alias sa Start-Process # default: saps, start
. $PSScriptRoot\..\Cmdlet\_alias.ps1

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
# use to store permanent values. share value between sessions:
# compare with ram disk and mem mapped files, the registry is also mem buffered and persistent, faster to share small objects
# no need to worry ram wasting(initial size, persistent or releasing), and releasing between sessions (memMappedFile is released when no reference to it)
if (-not (Test-Path "HKCU:\MS_PWSH")) {
    New-Item -Path "HKCU:\MS_PWSH"
}
New-PSDrive -Name PS -PSProvider Registry -Root "HKCU:\MS_PWSH" > $null
