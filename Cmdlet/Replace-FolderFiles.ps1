[CmdletBinding()]
param (
    # string to match
    [Parameter()]
    [object]
    [Alias('m')]
    $matches,

    # string to be used for replacement
    [Parameter()]
    [string]
    [Alias('r')]
    $replacement,

    # extensions for files to include in
    [Parameter()]
    [string[]]
    $exts = @('*.cs', '*.csproj', '*.sln', '*.resx', '*.targets', '*.xml', '*.config', '*.xaml', '*.json', '*.ts', '*.js', '*.md', '*.ps1'),

    # directories to exclude out
    [Parameter()]
    [string[]]
    $excludeDirs = '\\bin\\|\\obj\\|\\node_modules\|\\dist\\',

    # only rename files and directories
    [switch]$noContent
)

$matches |
% {
    Write-Step "Replace File/Dir Names"
    Write-Host "handling keyword: $_"
    $match = $_
    # git reset --hard origin/master
    # git clean -f -d
    ## rename file names
    $dir = get-location
    # not case sensitive
    # $files = Get-ChildItem $dir  -Recurse -filter "*$match*" | ? { $_.FullName -notmatch $excludeDirs }
    $sortedFiles = Get-ChildItem $dir  -Recurse | ? { $_.Name -cmatch $match -and $_.FullName -notmatch $excludeDirs }|
    # file processed first
    Sort-Object -Descending -Property FullName

    # create a temp var $sotredFiles before pipe the files to rename to avoid the error:
    # Access to the path 'file path' is denied.
    # which means we processed all items and buffer it the a list pointed by the temp var
    $sortedFiles |
    # | select FullName
    Rename-Item -force -newname {
        $newName = $_.name -creplace $match, $replacement
        Write-Notice "rename: $($_.FullName) to: $newName";
        return $newName
    }

    if ($noContent) { return }

    Write-Step "Replace File Contents"
    Get-ChildItem $dir -File -Recurse -include $exts |
    ? { $_.FullName -notmatch $excludeDirs } |
    % {
        ## replace file contents
        # () is important here: The process cannot access the file, because it is being used by another process.
        $name = $_.FullName
        (Get-Content $_ -Encoding utf8 -Raw) |
        % {
            if ($_ -match $match) {
                Write-Notice "Replace file content: $name"
                return $_ -creplace $match, $replacement
            }
            return $_
        } |
        set-content $_.fullname -Encoding UTF8 -Force -NoNewline
    }
}
## usage example: create a project Modbus from a ToDo template project
<#
copy .\ext-todo-plugin\* .\ext-opcua-plugin -Recurse -Container
# do it with -no-content switch first and commit then do it without the switch
$Key = 'ToDo', 'Todo'
$NewKey = 'Opcua' #'Modbus'
Replace-FileNameAndContent -match $Key -replace $NewKey -noContent
git add .
git commit -am "rename file and directory"
# note the a in the -am is 'all', otherwise it just add modified and deleted files not include added
Replace-FileNameAndContent -match $Key -replace $NewKey
git add .
git commit -am "rename file content"

#>