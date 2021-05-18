Set-Alias ga Get-Alias
Set-Alias gh Get-Help
# nsl: new directory and set location: make and change dir
Set-Alias nsl mcd
if(Test-Path "C:\Users\metaseed\AppData\Local\Programs\Microsoft VS Code Insiders\Code - Insiders.exe") {
    Set-Alias code code-insiders
}