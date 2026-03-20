<#
.SYNOPSIS
    remove duplicate values separated by ';' in the environment variable, by default 'Path'
    Note: Machine path is checked first.
#>
function Remove-EnvVarDuplicateValues {
    [CmdletBinding()]
    param (
        [Parameter()]
        # 'Path' or 'PSModulePath' ....
        $var = 'Path',
        [object]
        [ValidateSet('Machine', 'User')]
        $scope = 'User'
    )
    function clean {
        param (
            # Machine or User, default based on current Admin right
            [object]
            [ValidateSet('Machine', 'User')]
            $scope = $null,
            [switch]
            $removeDead
        )

        # trick: $scope is object not string, so we can use ??= with $null, note: empty string not work for ??=
        $scope ??= "User"

        $newPath = [System.Collections.ArrayList]::new()
        $v = [Environment]::GetEnvironmentVariable($var, $scope)

        if ($null -eq $v) {
            write-warning "scope: $scope, do not have the env var:$var"
            return
        }

        Write-Notice "current value of scope: $scope, env:$var = $v"

        write-host "process scope: $scope, env:$var..."
        try {
            $changed = $false
            $null = $v.Split(';') |
            % {
                if (!$_) { return } # return nothing in % to filter out it

                if ($removeDead -and -not (Test-Path $_)) {
                    write-host "remove dead path: $_" -ForegroundColor Yellow
                    $changed = $true
                    return # return nothing to filter it out
                }

                $hasDup = $false
                # getFullPath would not throw if path is not exist
                # resolve-path throw if not exist
                $path_test = [Path]::GetFullPath($_)
                foreach ($p in $newPath) {
                    if ($p.Equals($path_test, [StringComparison]::OrdinalIgnoreCase) ) {
                        $hasDup = $true
                        break
                    }
                }

                if (!$hasDup) {
                    $newPath.Add($path_test)
                }
                else {
                    $changed = $true
                    write-host "remove duplication: $_"
                }
            }

            if ($changed) {
                $p = $newPath -join ';'
                [Environment]::SetEnvironmentVariable($var, $p, $scope)
                Write-Notice "updated value of scope: $scope, env:$var"
            }
            else {
                Write-Notice "No duplication in scope: $scope, env:$var"
            }
            return $newPath
        }
        catch {
            Write-Notice "Error occurred while processing scope: $scope, env:$var, so recover the original value"
            [Environment]::SetEnvironmentVariable($var, $v, $scope)
        }
    }

    clean $scope
}

