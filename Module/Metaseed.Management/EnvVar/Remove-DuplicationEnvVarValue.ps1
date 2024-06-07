<#
.SYNOPSIS
    by default remove duplicate keys in the Path environment variable
#>
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
          $scope = $null,
          [switch]
          $keepDead
      )

      $isAdmin = Test-Admin
      # trick: $scope is object not string, so we can use ??=. empty string not work for ??=
      $scope ??= ($isAdmin ? "Machine": "User")

      $newPath = [System.Collections.ArrayList]::new()
      $v = [Environment]::GetEnvironmentVariable($var, $scope)
      if ($null -eq $v) {
          write-warning "scope: $scope, do not have the env var:$var"
          return
      }

      write-host "process scope: $scope, env:$var..."
      $null = $v.Split(';') |
      % {
          if (!$_) { return } # return nothing in % to filter out it

          if (-not $keepDead -and -not (Test-Path $_)) {
              write-host "remove dead path: $_"
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
              write-host "remove duplication: $_"
          }
      }
      $p = $newPath -join ';'
      [Environment]::SetEnvironmentVariable($var, $p, $scope)
  }

  clean 'User'
  clean 'Machine'
}