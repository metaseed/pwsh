# new variables
$env:MyDoc = [Environment]::GetFolderPath('MyDocument');
# [System.Environment]::GetFolderPath([System.Environment.SpecialFolder]::Desktop)
$env:Desktop = [Environment]::GetFolderPath("Desktop")
$env:HostsFilePath = "$env:windir\System32\drivers\etc\hosts"
# when in vscode $env:TERM_PROGRAM is vscode
$env:TERM_NERD_FONT = $env:WT_SESSION -or $env:TERM_PROGRAM
# $env:PSModulePath += ";$(Resolve-Path $PSScriptRoot\..\Module)"

$env:Path += ';M:\Workspace\ff\bin\Release\net9.0'
# hack: when run 'pwsh' the parent 'pwsh' is not closed, and the new 'pwsh' inherits the env vars
if ($env:ms_pwshPathPatched -ne 'true') {
    # env var is string, but here we can store $true too, it's process env, can be none-string

    $CmdLetFolder = $(Resolve-Path $PSScriptRoot\..\Cmdlet)
    . $CmdLetFolder\_\env.ps1

    $env:ms_pwshPathPatched = 'true'
}
