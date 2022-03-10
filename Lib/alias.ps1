Set-Alias ga Get-Alias
Set-Alias gh Get-Help
# nsl: new directory and set location: make and change dir
Set-Alias nsl mcd

# need to find a way to prevent leaking _admin to profile
function _admin () {
    Start-Process pwsh -verb runas
    exit 0
}
Set-Alias admin _admin

& { # prevent $codePath leak in to profile variable: provider
    $codePath = (Get-Command 'code' -ErrorAction SilentlyContinue).Source
    if ($null -eq $codePath) {
        $codePath = (Get-Command 'code-insiders' -ErrorAction SilentlyContinue).Source
        if ($null -ne $codePath) {
            # "C:\Users\metaseed\AppData\Local\Programs\Microsoft VS Code Insiders\Code - Insiders.exe"
            Set-Alias code code-insiders
        }
    }
}