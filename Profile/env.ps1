# new veriables
$env:MyDoc = [Environment]::GetFolderPath('MyDocument');
$env:HostFile = "$env:windir\System32\drivers\etc\hosts"
# config
$env:PSModulePath += ";$(Resolve-Path $PSScriptRoot\..\Module)"
$env:path += ";$(Resolve-Path $PSScriptRoot\..\Cmdlet)"
& { #prevent expose $appFolder into the profile variable: provider
    $appFolder = 'C:\App'
    if (Test-Path $appFolder) {
        #note: app folder has already been add to path when do mapping
        $env:path += ";" + ((Get-ChildItem -Attributes Directory -Path $appFolder -Name | ForEach-Object { join-path $appFolder $_ }) -join ';')
    }
}