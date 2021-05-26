using namespace System.IO
using module Admin
function Add-Path {
    param (
        # directory to add to path
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String]
        $Dir,
        # Machine or User, default based on current Admin right
        [string]
        $Scope
    )
    
    $Dir = [Path]::GetFullPath($Dir)

    if (-not (Test-PathInStr $env:Path $dir)) {
        $env:Path = "$dir;$env:Path"
        Write-Verbose "'$dir' was added to current `$env:Path"
    }
    else {
        Write-Verbose "current `$env:Path already contains $dir"
    }
    
    $isAdmin = Test-Admin
    $scope = $Scope ??($isAdmin ? "Machine": "User")
    $envPath = [Environment]::GetEnvironmentVariable("Path", $scope)
    $pathes = $isAdmin ?
            "$envPath;$([Environment]::GetEnvironmentVariable('Path', 'User'))" :
            "$envPath"

    if (-not (Test-PathInStr $pathes $dir)) {
        [Environment]::SetEnvironmentVariable("Path", "$dir;$envPath", $scope)
        Write-Verbose "'$dir' was added to Environment variable: Path"
    }
    else {
        Write-Verbose "`Envirionment Variable Path already contains $dir"
    }

}

function Test-PathInStr {
    [CmdletBinding()]
    param (
        [String] $PathStr,
        [String]$dir
    )
    $PathStr -split ';' |
    ? {
        if ([String]::IsNullOrEmpty($_)) { return $false }

        $path = [Path]::GetFullPath($_);
        $path.Equals([Path]::GetFullPath($dir), [StringComparison]::OrdinalIgnoreCase) 
    }
}   

