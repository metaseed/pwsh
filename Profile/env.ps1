# new veriables
$env:MyDoc = [Environment]::GetFolderPath('MyDocument');
# [System.Environment]::GetFolderPath([System.Environment.SpecialFolder]::Desktop)
$env:Desktop = [Environment]::GetFolderPath("Desktop")
$env:HostsFilePath = "$env:windir\System32\drivers\etc\hosts"
$env:TERM_NERD_FONT = $env:WT_SESSION -or $env:TERM_PROGRAM
# $env:PSModulePath += ";$(Resolve-Path $PSScriptRoot\..\Module)"

# hack: when run 'pwsh' the parent 'pwsh' is not closed, and the new 'pwsh' inherits the env vars
if ($env:ms_pwshPathPatched -ne 'true') {# env var is string, but here we can store $true too, it's process env, can be none-string

    # insert at head so that when 'lf' the alias is called
    $CmdLetFolder = $(Resolve-Path $PSScriptRoot\..\Cmdlet)
    $env:path = "$CmdLetFolder;$env:path"

    ## add important app path
    $env:path += ";C:\App\7-Zip"

    # -exclude only the leaf name start with '_'
    # -Name -Attribute Directory will return the dir path after $CmdLetFolder, i.e. a\aliases, a, then we do filter to remove the name contains '\_', tests folders, , 's\'
    # note: we only add paths to temp env:path here, not to saved path env of user or machine, so these paths only used by pwsh
    # note: the `-exclude string[]` only work on the first level of subfolder
    $folders = Get-ChildItem -Attributes Directory -Path $CmdLetFolder -Recurse -Exclude '_*','tests' -Name |?{ !($_ -match '\\_|\\tests\\?|^tests\\|s\\') } | % { "$CmdLetFolder\$_" }
    $env:path = "$($folders -join ';');$env:path"

    $env:ms_pwshPathPatched = 'true'
}
