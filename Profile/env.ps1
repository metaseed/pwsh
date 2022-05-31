# new veriables
$env:MyDoc = [Environment]::GetFolderPath('MyDocument');
$env:HostsFile = "$env:windir\System32\drivers\etc\hosts"
# config
$env:PSModulePath += ";$(Resolve-Path $PSScriptRoot\..\Module)"
& { #prevent expose $appFolder into the profile variable: provider
    $appFolder = 'C:\App'
    if (Test-Path $appFolder) {
        #note: app folder has already been add to path when do mapping
        $env:path += ";$((Get-ChildItem -Attributes Directory -Path $appFolder -Name | ForEach-Object { join-path $appFolder $_ }) -join ';')"
    }
    $CmdLetFolder = $(Resolve-Path $PSScriptRoot\..\Cmdlet)
    $env:path += ";$CmdLetFolder"
    $env:path += ";$((Get-ChildItem -Attributes Directory -Path $CmdLetFolder -Name -Recurse -Exclude _* | ForEach-Object { join-path $CmdLetFolder $_ }) -join ';')"
}