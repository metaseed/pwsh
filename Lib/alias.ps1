Set-Alias ga Get-Alias
Set-Alias gh Get-Help
# nsl: new directory and set location: make and change dir
Set-Alias nsl mcd

$Private:codePath = (Get-Command 'code' -ErrorAction SilentlyContinue).Source
if($null -eq $Private:codePath) {
    $Private:codePath = (Get-Command 'code-insiders' -ErrorAction SilentlyContinue).Source
    if($null -ne $Private:codePath) {
        # "C:\Users\metaseed\AppData\Local\Programs\Microsoft VS Code Insiders\Code - Insiders.exe"
        Set-Alias code code-insiders
    }
}