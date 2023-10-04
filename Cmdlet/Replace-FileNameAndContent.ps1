[CmdletBinding()]
param (
    # string to match
    [Parameter()]
    [object]
    [Alias('m')]
    $matches = "MTemplate",

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
    Write-Host "================================================================"
    Write-Host "handling keyword: $_"
    $match = $_
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
        Write-Host "Replace File Contents"
        Get-ChildItem $dir -File -Recurse -include $exts |
        ? { $_.FullName -notmatch $excludeDirs } |
        % {
            ## replace file contents
            # () is important here: The process cannot access the file, because it is being used by another process.
            $name = $_.FullName
        (Get-Content $_ -Encoding utf8 -Raw) |
            % {
                if ($_ -match $match) {
                    Write-Host "Replace file content: $name"
                    return $_ -creplace $match, $replacement
                }
                return $_
            } |
            set-content $_.fullname -Encoding UTF8 -Force -NoNewline
        }
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
# note the a in the -am is 'all', it just add modified and deleted files not include added
Replace-FileNameAndContent -match $Key -replace $NewKey
git add .
git commit -am "rename file content"

#>