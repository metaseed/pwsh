using namespace System.IO
function Add-PathEnv {
    param (
        # directory to add to path
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String]
        $Dir,
        # Machine or User, default based on current Admin right
        [object]
        [ValidateSet('Machine', 'User')]
        $Scope = $null,
        # prepend by default
        [switch]
        $append
    )

    # resolve-path return a PathInfo object
    $Dir = [Path]::GetFullPath($Dir)
    $PathToUse = $append ? "$env:path;$dir" : "$dir;$env:Path"

    if (-not (Test-PathInStr $env:Path $dir)) {
        $env:Path = $PathToUse
        Write-Verbose "'$dir' was added to current `$env:Path"
    }
    else {
        Write-Verbose "current `$env:Path already contains $dir"
    }

    $isAdmin = Test-Admin
    $scope = $Scope ?? ($isAdmin ? "Machine": "User")
    $envPath = [Environment]::GetEnvironmentVariable("Path", $scope)
    $pathes = $isAdmin ?
        "$envPath;$([Environment]::GetEnvironmentVariable('Path', 'User'))" :
        "$envPath"

    if (-not (Test-PathInStr $pathes $dir)) {
        [Environment]::SetEnvironmentVariable("Path", $PathToUse, $scope)
        Write-Verbose "'$dir' was added to Environment $scope scope variable: Path"
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

# Add-PathEnv $env:ProgramFiles\Git\mingw64\bin