using namespace System.IO

<#
Environment Variables scopes:
User: User-specific environment variable
Machine: System-wide environment variable

Process: Current process environment variable:
    1. System-wide environment variable loaded first
    2. User-specific environment variable loaded second, can override the system-wide environment variable
    3. Process specific environment variable loaded last, can override aboves

But for the Path env:
Windows searches for that executable in a very specific order:
    1. Current Directory: It looks exactly where your terminal is currently pointed.
    2. System Path: It scans every folder listed in the System variables.
    3. User Path: Only if it finds nothing in the first two steps does it check your personal User Path.
> that means the system path will override path. i.e. If you have Python 3.12 installed in your System Path, but you want to use Python 3.13 located in your User Path, typing python will launch version 3.12.

NOTE:
* $env:<varName> is the current process environment variable
* app run in user mode, can read both user and system variables, so the process environment variable is a combination of all three scopes, same for the admin mode app.
* but, the user mode app can only modify the process environment variables and user environment variables, not the machine environment variables, the admin app can modify the machine environment variables too.
#>

<#
add dir to 'Machine' or 'User' Path env variable, and update the process env.
if already has it, do nothing
#>
function Add-PathEnv {
    param (
        # directory to add to path
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String]
        $Dir,
        # Machine or User, default: user
        [object]
        [ValidateSet('Machine', 'User')]
        $Scope = 'User',
        # prepend by default
        [switch]
        $append
    )

    # resolve-path return a PathInfo object
    $Dir = [Path]::GetFullPath($Dir)

    if (-not (Test-DirInPathStr $env:Path $Dir)) {
        $PathToUse = $append ? "$env:path;$Dir" : "$Dir;$env:Path"
        $env:Path = $PathToUse
        Write-Information "'$Dir' was added to current `$env:Path"
    }
    else {
        Write-Information "`$env:Path already contains $Dir, skip adding"
    }
    $isAdmin = Test-Admin

    $envPathUser = [Environment]::GetEnvironmentVariable("Path", 'User')
    $envPathMachine = [Environment]::GetEnvironmentVariable("Path", 'Machine')
    if (Test-DirInPathStr $envPathUser $Dir) {
        Write-Warning "'User' Environment Variable Path already contains $Dir, not need to add it"
        return
    }
    if (Test-DirInPathStr $envPathMachine $Dir) {
        Write-Warning "'Machine' Environment Variable Path already contains $Dir, not need to add it"
        return
    }

    if(!$IsAdmin -and $Scope -eq 'Machine') {
        Write-Warning "You are not running as Admin, cannot modify Machine environment variables"
        return
    }

    $PathToUse = $Scope -eq 'User' ? $envPathUser : $envPathMachine
    $PathToUse = $append ? "$PathToUse;$Dir" : "$Dir;$PathToUse"

    [Environment]::SetEnvironmentVariable("Path", $PathToUse, $Scope)
    Write-Information "'$Dir' was added to Environment $Scope scope variable: Path"
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

function Remove-PathEnv {
    param (
        # directory to remove from path
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String]
        $Dir,
        [ValidateSet('User', 'Machine', 'Process', 'All')]
        $Scope = 'All'
    )

    # resolve-path return a PathInfo object
    $Dir = [Path]::GetFullPath($Dir)

    if (($Scope -eq 'All' -or $Scope -eq 'Process') -and (Test-DirInPathStr $env:Path $Dir)) {
        $env:Path = Remove-DirFromPathStr $env:Path $Dir
        Write-Information "'$Dir' was removed from current Process's `$env:Path"
    }
    else {
        Write-Information "current `$env:Path does not contain $Dir"
    }

    $IsAdmin = Test-Admin
    $EnvPathUser = [Environment]::GetEnvironmentVariable("Path", 'User')
    $EnvPathMachine = [Environment]::GetEnvironmentVariable("Path", 'Machine')
    if (($Scope -eq 'All' -or $Scope -eq 'User') -and (Test-DirInPathStr $EnvPathUser $Dir)) {
        $EnvPathUser = Remove-DirFromPathStr $EnvPathUser $Dir
        [Environment]::SetEnvironmentVariable("Path", $EnvPathUser, 'User')
        Write-Information "'$Dir' was removed from Environment User scope variable: Path"
        return
    }

    if (($Scope -eq 'All' -or $Scope -eq 'Machine') -and (Test-DirInPathStr $EnvPathMachine $Dir)) {
        if(!$IsAdmin) {
            Write-Warning "Find the $Dir in the Machine environment variables, `nbut you are NOT running as Admin, cannot modify Machine environment variables"
            return
        }

        $EnvPathMachine = Remove-DirFromPathStr $EnvPathMachine $Dir
        [Environment]::SetEnvironmentVariable("Path", $EnvPathMachine, 'Machine')
        Write-Information "'$Dir' was removed from Environment Machine scope variable: Path"
        return
    }

}

function Remove-DirFromPathStr {
    [CmdletBinding()]
    param (
        [String]$PathStr,
        [String]$Dir
    )
    $list = $PathStr -split ';' |
    Where-Object {
        if ([String]::IsNullOrEmpty($_)) { return $false }

        try {
            $path = [Path]::GetFullPath($_);
            -not $path.Equals([Path]::GetFullPath($Dir), [StringComparison]::OrdinalIgnoreCase)
        }
        catch {
            $true
        }
    }
    $list -join ';'
}

Export-ModuleMember -Function Remove-PathEnv

# Test-DirInPathStr "c:\temp;d:\temp" "c:\temp"

# Add-PathEnv C:\ProgramFiles\Git\mingw64\bin