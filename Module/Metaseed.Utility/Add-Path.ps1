using namespace System.IO
function Add-Path {
    param (
        # directory to add to path
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String]
        $Dir,
        # Machine or User, default based on current Admin right
        [object]
        $Scope = $null
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
    $scope = $Scope ?? ($isAdmin ? "Machine": "User")
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

function Remove-DuplicationEnvVarValue {
    [CmdletBinding()]
    param (
        [Parameter()]
        # 'Path' or 'PSModulePath' ....
        $var = 'Path'
    )
    function clean {
    
        param (
            # Machine or User, default based on current Admin right
            [object]
            [ValidateSet('Machine', 'User')]
            $scope = $null
        )

        $isAdmin = Test-Admin
        # trick: $scope is object not string, so we can use ??=. empty string not work for ??=
        $scope ??= ($isAdmin ? "Machine": "User")

        $newPath = [System.Collections.ArrayList]::new()
        $v = [Environment]::GetEnvironmentVariable($var, $scope)
        if ($null -eq $v) {
            write-warning "scope: $scope, do not have env:$var"
            return
        }
        "process scope: $scope, env:$var..."
        $null = $v.Split(';') |
        % {
            if(!$_) {return}
            $dup = $false
            $path_test = [Path]::GetFullPath($_)
            foreach ($p in $newPath) {
                if ($p.Equals($path_test, [System.StringComparison]::OrdinalIgnoreCase) ) {
                    $dup = $true
                    break
                }
            }

            if (!$dup) {
                $newPath.Add($path_test)
            }
            else {
                write-host "remove duplication: $_"
            }
        }
        $p = $newPath -join ';'
        [Environment]::SetEnvironmentVariable($var, $p, $scope)
    }
    clean 'User'
    clean 'Machine'
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

# Add-Path $env:ProgramFiles\Git\mingw64\bin
Export-ModuleMember -Function Remove-DuplicationEnvVarValue