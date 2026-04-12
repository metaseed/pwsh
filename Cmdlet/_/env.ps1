# included in `profile/env.ps1`
# insert at head so that when 'lf' the alias is called
$CmdLetFolder = Resolve-Path "$PSScriptRoot\.."
$env:path = "$CmdLetFolder;$env:path"

## add important app path
# $env:path += ";C:\App\7-Zip"

# -exclude only the leaf name start with '_'(here it's dir: -Attributes Directory)
# -Name -Attribute Directory will return the dir path after $CmdLetFolder, i.e. a\aliases, a, then we do filter to remove the leaf part name start with '_', tests folders
# note: the `-exclude string[]` only work on the first level of subfolder, i.e. the `tests` folder directly in the folder

# note: we only add paths to temp env:path here, not to saved path env of user or machine, so these paths only used by pwsh
# cached to avoid slow Get-ChildItem -Recurse on every profile load (~77ms saved)
$__cmdletPathCache = "$env:LOCALAPPDATA\pwsh-profile-cache\cmdlet-paths.txt"
if (Test-Path $__cmdletPathCache) {
    $env:path = "$(Get-Content $__cmdletPathCache -Raw);$env:path"
} else {
    $folders = Get-ChildItem -Attributes Directory -Path $CmdLetFolder -Recurse -Exclude '_*','*_', 'tests' -Name |?{ !($_ -match '\\_|\\tests\\?|^tests\\|s\\') } | % { "$CmdLetFolder\$_" }
    $joined = $folders -join ';'
    $env:path = "$joined;$env:path"
    $null = New-Item -ItemType Directory -Path (Split-Path $__cmdletPathCache) -Force -ErrorAction Ignore
    Set-Content -Path $__cmdletPathCache -Value $joined -Force -NoNewline
}
# rm $__cmdletPathCache