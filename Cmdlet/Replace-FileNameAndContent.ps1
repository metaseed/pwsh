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
    $exts = ('*.cs', '*.csproj', '*.sln', '*.resx', '*.targets', '*.xml', '*.config', '*.xaml')
)

## rename file names
$dir = get-location
$files = Get-ChildItem $dir -filter "*$match*" -Recurse

$files |
Sort-Object -Descending -Property FullName |
Rename-Item -newname { $_.name -replace $match, $replacement } -force

## rename file contents
Get-ChildItem $dir -include $exts -Recurse |
% { Get-Content $_.fullname -Encoding UTF8 |
    % { $_ -creplace $match, $replacement } |
    set-content $_.fullname -Encoding UTF8 
}
