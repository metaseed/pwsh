Set-Alias ga Get-Alias
Set-Alias gh Get-Help

& { # prevent $codePath leak in to profile variable: provider
    $codePath = (Get-Command 'code' -ErrorAction SilentlyContinue).Source
    if ($null -eq $codePath) {
        $codePath = (Get-Command 'code-insiders' -ErrorAction SilentlyContinue).Source
        if ($null -ne $codePath) {
            # "C:\Users\metaseed\AppData\Local\Programs\Microsoft VS Code Insiders\Code - Insiders.exe"
            Set-Alias code code-insiders -Scope Global
        }
    }
}