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
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]$Name,

        [Parameter(Mandatory, Position = 1)]
        [string]$Value,

        # target Machine scope instead of User
        [Alias('m')]
        [switch]$Machine
    )
    $Value = Regulate-IfIsFullPath $Value
    $persistScope = if ($Machine) { 'Machine' } else { 'User' }

    if ($Machine -and -not (Test-Admin)) {
        Write-Warning "You are not running as Admin, cannot modify Machine environment variables"
        return
    }

    function Set-EnvVarValueByScope($Name, $Value, $persistScope) {
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
    Set-EnvVarValueByScope $Name $Value 'Process'
    Set-EnvVarValueByScope $Name $Value $persistScope

}

function Regulate-IfIsFullPath {
    <#
    .SYNOPSIS
        Normalizes the path if it is already an absolute (rooted) path.
        If the path is not rooted, returns the original input unchanged.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # 1. Check for illegal characters
    $invalidChars = [System.IO.Path]::GetInvalidPathChars()
    if ($Path.ToCharArray().Where{ $invalidChars -contains $_ }) {
        Write-Warning "Path contains invalid characters, returning original input."
        return $Path
    }

    # 2. Check if the path is rooted
    if (-not [System.IO.Path]::IsPathRooted($Path)) {
        # Return original input if not an absolute path
        return $Path
    }

    # 3. If it IS rooted, attempt to normalize (resolve dots and separators)
    try {
        return [System.IO.Path]::GetFullPath($Path)
    }
    catch {
        Write-Warning "Failed to normalize rooted path, returning original input."
        return $Path
    }
}

# Examples:
# Regulate-FullPath "C:/Users/Documents/../Desktop"
# Output: C:\Users\Desktop (Windows automatically converts / to \)

# Export-ModuleMember -Function Set-EnvVar -Alias setv