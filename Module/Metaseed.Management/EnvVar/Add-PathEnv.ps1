using namespace System.IO

<#
add dir to 'Machine' or 'User' Path env variable, both temp and persistent
#>
function Add-PathEnv {
    param (
        # directory to add to path
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String]
        $Dir,
        # Machine or User, default: if the session is Admin, use the Machine scope
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

    if (-not (Test-DirInPathStr $env:Path $dir)) {
        $env:Path = $PathToUse
        Write-Verbose "'$dir' was added to current `$env:Path"
    }
    else {
        Write-Verbose "current `$env:Path already contains $dir"
    }

    $isAdmin = Test-Admin
    $scope = $Scope ?? ($isAdmin ? "Machine": "User")

    $envPath = [Environment]::GetEnvironmentVariable("Path", $scope)
    if (Test-DirInPathStr $envPath $dir) {
        Write-Verbose "Envirionment Variable Path already contains $dir in scope:$scope"
        return
    }

    if ($scope -eq "Machine") {
        $envPathUser = $([Environment]::GetEnvironmentVariable('Path', 'User'))
        if (Test-DirInPathStr $envPathUser $dir) {
            Write-Verbose "Envirionment Variable Path already contains $dir in scope:User"
            return
        }
    }

    $PathToUse = $append ? "$envPath;$dir" : "$dir;$envPath"
    [Environment]::SetEnvironmentVariable("Path", $PathToUse, $scope)
    Write-Verbose "'$dir' was added to Environment $scope scope variable: Path"
}

function Test-DirInPathStr {
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

# Test-DirInPathStr "c:\temp;d:\temp" "c:\temp"

# Add-PathEnv C:\ProgramFiles\Git\mingw64\bin