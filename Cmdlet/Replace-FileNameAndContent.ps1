[CmdletBinding()]
param (
    [Parameter()]
    [string]
    [Alias('m')]
    $match = "MTemplate",

    # string to replated
    [Parameter()]
    [string]
    [Alias('r')]
    $replacement,
    # extensions to filter
    [Parameter()]
    [string[]]
    $exts = @('*.cs', '*.csproj', '*.sln', '*.resx', '*.targets', '*.xml', '*.config', '*.xaml', '*.json', '*.md', '*.ps1'),

    [Parameter()]
    [string[]]
    $excludeDirs = '\\bin\\|\\obj\\',

    [switch]$noContent

)
# git reset --hard origin/master
# git clean -f -d
## rename file names
$dir = get-location
$files = Get-ChildItem $dir  -Recurse -filter "*$match*" | ? { $_.FullName -notmatch $excludeDirs }

$files |
Sort-Object -Descending -Property FullName |
# | select FullName
Rename-Item -force -newname {
    write-host "rename: $($_.FullName)";
    return $_.name -replace $match, $replacement
}

if (!$noContent) {
    ## replace file contents
    Get-ChildItem $dir -include $exts -Recurse |
    ? { $_.FullName -notmatch $excludeDirs } |
    % {
    (Get-Content $_.fullname -Encoding UTF8 -Raw) |
        % { $_ -creplace $match, $replacement } |
        set-content $_.fullname -Encoding UTF8 -Force -NoNewline
    }
}
