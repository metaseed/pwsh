[CmdletBinding()]
param (
    [Parameter()]
    [string]
    [Alias('m')]
    $Match = "MTemplate",

    # string to replated
    [Parameter()]
    [string]
    [Alias('r')]
    $replacement
)

$files = Get-ChildItem $(get-location) -filter "*$match*" -Recurse

$files |
Sort-Object -Descending -Property FullName |
Rename-Item -newname { $_.name -replace $match, $replacement } -force


Get-ChildItem $(get-location) -include *.cs, *.csproj, *.sln, *.resx, *.targets, *.xml, *.config, *.xaml -Recurse |
% { (Get-Content $_.fullname -Encoding UTF8) |
    % { $_ -creplace $match, $replacement } |
    set-content $_.fullname -Encoding UTF8 
}
