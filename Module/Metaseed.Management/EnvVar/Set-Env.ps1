<#
.SYNOPSIS
   Set environment variable in one call. Default: Process + User scope.
.DESCRIPTION
   Sets an environment variable in the Process scope and a persistent scope.
   By default the persistent scope is User. Use -m to target Machine instead.
.EXAMPLE
   Set-Env MY_VAR "hello"        # sets in Process + User
   Set-Env MY_VAR "hello" -m     # sets in Process + Machine (requires Admin)
#>
function Set-Env {
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

    # set in current process
    [Environment]::SetEnvironmentVariable($Name, $Value, 'Process')

    # persist to User or Machine
    [Environment]::SetEnvironmentVariable($Name, $Value, $persistScope)

    Write-Verbose "Set '$Name' = '$Value' in Process and $persistScope scope"
}

# Export-ModuleMember -Function Set-Env -Alias setv