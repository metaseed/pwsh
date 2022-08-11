# new veriables
$env:MyDoc = [Environment]::GetFolderPath('MyDocument');
$env:HostsFile = "$env:windir\System32\drivers\etc\hosts"
# config
# $env:PSModulePath += ";$(Resolve-Path $PSScriptRoot\..\Module)"
& { #prevent expose $appFolder into the profile variable: provider
    # hack: when run 'pwsh' the parent 'pwsh' is not closed, and the new 'pwsh' inherits the env vars
    if(!$env:pathPatched) {
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
        # -Name will return the dir path after $CmdLetFolder, then we do filter to remove the name contains '\_', '\test', '\s\'
        $folders = Get-ChildItem -Attributes Directory -Path $CmdLetFolder -Recurse -Exclude '_*' -Name|? {$_ -notmatch '\\_|\\test|\\s\\'}|% {"$CmdLetFolder\$_"}
        $env:path += ";$($folders -join ';')"

        $env:pathPatched = $true
    }
}