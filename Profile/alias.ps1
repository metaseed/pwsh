Set-Alias ga Get-Alias
Set-Alias ghp Get-Help # gh collide with gh.exe github cli
. $PSScriptRoot\..\Cmdlet\_alias.ps1

& { # prevent $codePath leak in to profile variable: provider
    $codePath = (Get-Command 'code' -ErrorAction Ignore).Source
    if ($null -eq $codePath) {
        $codePath = (Get-Command 'code-insiders' -ErrorAction Ignore).Source
        if ($null -ne $codePath) {
            # "C:\Users\metaseed\AppData\Local\Programs\Microsoft VS Code Insiders\Code - Insiders.exe"
            Set-Alias code code-insiders -Scope Global
        }
    }
}