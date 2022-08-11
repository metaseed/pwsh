# new veriables
$env:MyDoc = [Environment]::GetFolderPath('MyDocument');
$env:HostsFile = "$env:windir\System32\drivers\etc\hosts"
# config
# $env:PSModulePath += ";$(Resolve-Path $PSScriptRoot\..\Module)"
& { #prevent expose $appFolder into the profile variable: provider
    $appFolder = 'C:\App'

    if (Test-Path $appFolder) {
        $depth = 2
        # $env:path += ";$appFolder;$((Get-ChildItem -Attributes Directory -Path $appFolder -Depth $depth -Name | ForEach-Object { join-path $appFolder $_ } |? {!!(gci "$_/*.exe") }) -join ';')"
        $exes =gci -path "$appFolder" -filter *.exe -depth $depth -Force

        # if (Test-Path "$appFolder\software") {
        #     $exes +=gci -path "$appFolder\software" -filter *.exe -depth $depth -Force
        # }
        $env:path += ";$(($exes.Directory.FullName | get-unique) -join ';' )"
    }
    $CmdLetFolder = $(Resolve-Path $PSScriptRoot\..\Cmdlet)
    $env:path += ";$CmdLetFolder"
    $folders = (Get-ChildItem -Attributes Directory -Path $CmdLetFolder -Recurse -Exclude '_*').FullName |? {$_ -notmatch '\\_|\\test'}
    $env:path += ";$($folders -join ';')"
}