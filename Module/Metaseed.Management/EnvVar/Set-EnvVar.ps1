<#
.SYNOPSIS
   Set environment variable in one call. Default: Process + User scope.
.DESCRIPTION
   Sets an environment variable in the Process scope and a persistent scope.
   By default the persistent scope is User. Use -m to target Machine instead.
.EXAMPLE
   Set-EnvVar MY_VAR "hello"        # sets in Process + User
   Set-EnvVar MY_VAR "hello" -m     # sets in Process + Machine (requires Admin)
#>
function Set-EnvVar {
    [Alias('setv')]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$Name,

        [Parameter(Mandatory, Position = 1)]
        [string]$Value,

        # target Machine scope instead of User
        [Alias('m')]
        [switch]$Machine
    )

    $persistScope = if ($Machine) { 'Machine' } else { 'User' }

    if ($Machine -and -not (Test-Admin)) {
        Write-Warning "You are not running as Admin, cannot modify Machine environment variables"
        return
    }

    function Set-ValueToScope($Name, $Value, $persistScope) {
        $v = [Environment]::GetEnvironmentVariable($Name, $persistScope)
        if ($v) {
            Write-Information "Original value: '$Name' is '$Value' ($persistScope scope)"
            if ($v -eq $Value) {
                Write-Warning "Original value is the same as the value to set in $persistScope scope"
            }
            else {
                [Environment]::SetEnvironmentVariable($Name, $Value, $persistScope)
                Write-Information "Set '$Name' = '$Value' ($persistScope scope)"
            }
        }
    }
    Set-ValueToScope $Name $Value 'Process'
    Set-ValueToScope $Name $Value $persistScope

}

# Export-ModuleMember -Function Set-EnvVar -Alias setv