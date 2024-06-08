# new veriables
# Measure-Script {
$env:MyDoc = [Environment]::GetFolderPath('MyDocument');
# [System.Environment]::GetFolderPath([System.Environment.SpecialFolder]::Desktop)
$env:Desktop = [Environment]::GetFolderPath("Desktop")
$env:HostsFilePath = "$env:windir\System32\drivers\etc\hosts"

# $env:PSModulePath += ";$(Resolve-Path $PSScriptRoot\..\Module)"
# & { #prevent expose $appFolder into the profile variable: provider
# hack: when run 'pwsh' the parent 'pwsh' is not closed, and the new 'pwsh' inherits the env vars
if ($env:ms_pwshPathPatched -ne 'true') {
    #env var is string
    # no need to add app folder to path
    # $appFolder = 'C:\App'
    # if (Test-Path $appFolder) {
    #     $depth = 2
    #     $exes =gci -path "$appFolder" -filter *.exe -depth $depth -Force

    #     # if (Test-Path "$appFolder\software") {
    #     #     $exes +=gci -path "$appFolder\software" -filter *.exe -depth $depth -Force
    #     # }
    #     $env:path += ";$(($exes.Directory.FullName | get-unique) -join ';' )"
    # }
    # $timer = [Timers.Timer]::new(3000)
    # $timer.AutoReset = $false
    # $null = Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {
    # write-host "ddd"

    # insert at head so that when 'lf' the alias is called
    $CmdLetFolder = $(Resolve-Path $PSScriptRoot\..\Cmdlet)
    $env:path = "$CmdLetFolder;$env:path"

    # -exclude only explude the leaf name start with '_'
    # -Name will return the dir path after $CmdLetFolder, then we do filter to remove the name contains '\_', '\test', '\s\'
    # note: we only add paths to temp env:path here, not to saved path env of user or machine, so these paths only used by pwsh
    $folders = Get-ChildItem -Attributes Directory -Path $CmdLetFolder -Recurse -Exclude '_*' -Name | ? { !($_ -match '\\_|\\?test\\?') } | % { "$CmdLetFolder\$_" } # |\\?s\\
    $env:path = "$($folders -join ';');$env:path"

    $env:ms_pwshPathPatched = 'true'
    #     $timer.Dispose()
    # }
    # $timer.start()
}
# }
# }