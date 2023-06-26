[CmdletBinding()]
param (
    # string to match
    [Parameter()]
    [string]
    [Alias('m')]
    $match = "MTemplate",

    # string to be used for replacement
    [Parameter()]
    [string]
    [Alias('r')]
    $replacement,

    # extensions for files to include in
    [Parameter()]
    [string[]]
    $exts = @('*.cs', '*.csproj', '*.sln', '*.resx', '*.targets', '*.xml', '*.config', '*.xaml', '*.json','*.ts', '*.js', '*.md', '*.ps1'),

    # directories to exclude out
    [Parameter()]
    [string[]]
    $excludeDirs = '\\bin\\|\\obj\\|\\node_modules\|\\dist\\',

    # only rename files and directories
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
    $newName = $_.name -replace $match, $replacement
    write-host "rename: $($_.FullName) to: $newName";
    return $newName
}

if (!$noContent) {
    ## replace file contents
    Get-ChildItem $_ -File -include $exts -Recurse |
    ? { $_.FullName -notmatch $excludeDirs } |
    % {
        $name = $_.FullName
        (Get-Content $_.fullname -Encoding UTF8 -Raw) |
        % {
            if ($_ -match $match) {
                Write-Host "replace file content: $name"
                return $_ -creplace $match, $replacement
            }
            return $_
        } |
        set-content $_.fullname -Encoding UTF8 -Force -NoNewline
    }
}

# do it with -no-content switch first and commit then do it without the switch
# Replace-FileNameAndContent -match Todo -replace Modbus -noContent
# git add .
# git commit -am "rename file and directory"
# note the a in the -am is all it just add modified and deleted files not include added
# Replace-FileNameAndContent -match Todo -replace Modbus
# git add .
# git commit -am "rename file content"