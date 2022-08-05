# new veriables
$env:MyDoc = [Environment]::GetFolderPath('MyDocument');
$env:HostsFile = "$env:windir\System32\drivers\etc\hosts"
# config
# $env:PSModulePath += ";$(Resolve-Path $PSScriptRoot\..\Module)"
& { #prevent expose $appFolder into the profile variable: provider
    $appFolder = 'C:\App'

    if (Test-Path $appFolder) {
        $env:path += ";$appFolder;$((Get-ChildItem -Attributes Directory -Path $appFolder -Depth 2 -Name | ForEach-Object { join-path $appFolder $_ }) -join ';')"
        if (Test-Path "$appFolder\software") {
            $env:path += ";$((Get-ChildItem -Attributes Directory -Depth 2 -Path ("$appFolder\software") -Name | ForEach-Object { join-path "$appFolder\software" $_ }) -join ';')"
        }
    }
    $CmdLetFolder = $(Resolve-Path $PSScriptRoot\..\Cmdlet)
    $env:path += ";$CmdLetFolder"
    $env:path += ";$((Get-ChildItem -Attributes Directory -Path $CmdLetFolder -Name -Recurse -Exclude _* | ForEach-Object { join-path $CmdLetFolder $_ }) -join ';')"
}